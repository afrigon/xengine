import XEngineCore
import MetalKit

class MetalRenderer {
    private(set) var repository: ResourceRepository
    
    private let colorPixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    private let depthStencilPixelFormat: MTLPixelFormat = .depth32Float_stencil8
    
    private var device: MTLDevice
    private var library: MTLLibrary
    private var commandQueue: MTLCommandQueue
    
    private lazy var depthStencilState: MTLDepthStencilState = {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = true
        descriptor.depthCompareFunction = .less

        guard let depthStencilState = device.makeDepthStencilState(descriptor: descriptor) else {
            fatalError("Failed to create depth-stencil state.")
        }
        
        return depthStencilState
    }()

    private var sceneRenderTarget: ColorDepthRenderTarget
    private var postRenderTargetA: ColorRenderTarget
    private var postRenderTargetB: ColorRenderTarget
    private var outputRenderTarget: ScreenColorRenderTarget


    init?() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = try? device.makeDefaultLibrary(bundle: Bundle.module),
              let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        
        self.device = device
        self.repository = .init(device: device)
        self.library = library
        self.commandQueue = commandQueue
        
        self.sceneRenderTarget = ColorDepthRenderTarget(colorFormat: colorPixelFormat, depthFormat: depthStencilPixelFormat)
        self.postRenderTargetA = ColorRenderTarget(colorFormat: colorPixelFormat)
        self.postRenderTargetB = ColorRenderTarget(colorFormat: colorPixelFormat)
        self.outputRenderTarget = ScreenColorRenderTarget(colorFormat: colorPixelFormat)
    }
    
    func setup(with view: MTKView) {
        view.device = device
        view.colorPixelFormat = colorPixelFormat
        view.depthStencilPixelFormat = depthStencilPixelFormat
        
        resizeTextures(width: Int(view.frame.width), height: Int(view.frame.height))
    }
    
    func resize(width: UInt32, height: UInt32) {
        resizeTextures(width: Int(width), height: Int(height))
    }
    
    private func resizeTextures(width: Int, height: Int) {
        guard width > 0 && height > 0 else {
            return
        }
        
        sceneRenderTarget.resize(width: Int(width), height: Int(height), device: device)
        postRenderTargetA.resize(width: Int(width), height: Int(height), device: device)
        postRenderTargetB.resize(width: Int(width), height: Int(height), device: device)
        outputRenderTarget.resize(width: Int(width), height: Int(height), device: device)
    }
    
    func draw(scene: GameScene, globals: Globals, in view: MTKView) {
        // resources management load / clean
        // ideas: ref count + periodic purge if above memory quota
        // for the pokemon project all asset should fit into ram without any problem
        
        // TODO: add some rate limiting semaphore thing?? research why I had that in the other project
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        drawFrame(on: drawable) { commandBuffer in
            guard let sceneTexture = drawScene(scene: scene, globals: globals, commandBuffer: commandBuffer) else {
                return
            }
            
            let processed = drawPost(from: sceneTexture, effects: scene.camera.postProcessing.effects, commandBuffer: commandBuffer)
            
            // this is where UI element would be rendered but it is not supported yet.
            // The intended way of doing UI is to layer SwiftUI on top of the MetalView.
            
            drawOutput(from: processed, to: drawable.texture, commandBuffer: commandBuffer)
        }
    }
    
    private func drawScene(scene: GameScene, globals: Globals, commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        sceneRenderTarget.setClearColor(scene.camera.clear)
        
        guard let descriptor = sceneRenderTarget.renderPassDescriptor,
              let sceneEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Failed to make render command encoder.")
        }
        
        sceneEncoder.label = "Scene Encoder"

        sceneEncoder.setDepthStencilState(depthStencilState)
        sceneEncoder.setCullMode(.back)
        sceneEncoder.setFrontFacing(.clockwise)
        sceneEncoder.setTriangleFillMode(scene.camera.wireframe ? .lines : .fill)
        
        var globals = globals
        
        let renderable = scene.collectObjectsWithComponents(MeshRenderer.self)
        // TODO: filter visible objects
        
        let meshRenderers = renderable.compactMap { $0.getComponent(MeshRenderer.self) }
        
        let entries = meshRenderers
            .map {
                (
                    transform: $0.parent?.transform ?? .init(),
                    identifier: RenderableIdentifier(
                        shader: repository.getShaderIdentifier(for: $0.material, type: .basic),
                        material: $0.material,
                        mesh: $0.mesh
                    )
                )
            }
            .sorted(by: { $0.identifier < $1.identifier })
        
        var lastShader: String? = nil
        var lastMaterial: String? = nil
        var lastMesh: String? = nil
        
        var pipeline: MTLRenderPipelineState? = nil
        var material: Material? = nil
        var mesh: MetalMesh? = nil

        for entry in entries {
            if lastShader != entry.identifier.shader {
                pipeline = repository.createOrGetShader(entry.identifier.shader) {
                    self.createRenderPipelineState(entry.identifier.shader)
                }
                
                sceneEncoder.setRenderPipelineState(pipeline!)

                lastShader = entry.identifier.shader
            }
            
            if lastMaterial != entry.identifier.material {
                // do material loading stuff + texture
                material = repository.materials[entry.identifier.material]
                
                if let material {
                    switch material {
                        case .unlitColor(let m):
                            sceneEncoder.setFragmentBytes([m.color], length: MemoryLayout.size(ofValue: m.color), index: 1)
                    }
                }
                
                lastMaterial = entry.identifier.material
            }
            
            if lastMesh != entry.identifier.mesh {
                mesh = repository.meshes[entry.identifier.mesh]
                
                sceneEncoder.setVertexBuffer(mesh!.verticesBuffer, index: 1)
                sceneEncoder.setVertexBuffer(mesh!.normalsBuffer, index: 2)
                sceneEncoder.setVertexBuffer(mesh!.tangentsBuffer, index: 3)
                sceneEncoder.setVertexBuffer(mesh!.uv0Buffer, index: 4)

                lastMesh = entry.identifier.mesh
            }
            
            if let mesh {
                globals.modelMatrix = entry.transform.matrix
                globals.modelViewProjectionMatrix = scene.camera.viewProjectionMatrix * entry.transform.matrix
                globals.normalMatrix = entry.transform.matrix3x3
                
                sceneEncoder.setVertexBytes(
                    [globals],
                    length: MemoryLayout.size(ofValue: globals),
                    index: 0
                )
                
                sceneEncoder.setFragmentBytes(
                    [globals],
                    length: MemoryLayout.size(ofValue: globals),
                    index: 0
                )

                sceneEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: mesh.indicesCount,
                    indexType: .uint32,
                    indexBuffer: mesh.indicesBuffer,
                    indexBufferOffset: 0
                )
            }
        }
        
        sceneEncoder.endEncoding()
        
        return sceneRenderTarget.colorTexture
    }
    
    private func drawPost(from input: MTLTexture, effects: [PostProcessingEffect], commandBuffer: MTLCommandBuffer) -> MTLTexture {
        var output: MTLTexture = input
        var usingA: Bool = true
        
        for effect in effects {
            guard let descriptor = usingA ? postRenderTargetA.renderPassDescriptor : postRenderTargetB.renderPassDescriptor,
                  let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                fatalError("Failed to make render command encoder.")
            }
            encoder.label = "Post Processing Encoder \(usingA ? "A" : "B") (\(effect.shader))"
            
            guard let target = usingA ? postRenderTargetA.colorTexture : postRenderTargetB.colorTexture else {
                continue
            }
            
            drawPostLayer(
                from: output,
                to: target,
                effect: effect,
                postEncoder: encoder
            )
            
            usingA = !usingA
            output = target
        }
        
        return output
    }
    
    private func drawPostLayer(
        from input: MTLTexture,
        to output: MTLTexture,
        effect: PostProcessingEffect,
        postEncoder: MTLRenderCommandEncoder
    ) {
        let pipeline = repository.createOrGetShader(effect.shader) {
            self.createPostRenderPipelineState(effect.shader)
        }
        
        postEncoder.setRenderPipelineState(pipeline)
        
        postEncoder.setFragmentTexture(input, index: 0)
        
        switch effect {
            case .fxaa(let options):
                postEncoder.setFragmentBytes([options], length: MemoryLayout.size(ofValue: options), index: 1)
            default:
                break
        }
        
        postEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        postEncoder.endEncoding()
    }
    
    private func drawOutput(from input: MTLTexture, to output: MTLTexture, commandBuffer: MTLCommandBuffer) {
        outputRenderTarget.set(color: output)
        
        guard let descriptor = outputRenderTarget.renderPassDescriptor,
              let outputEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Failed to make render command encoder.")
        }
        outputEncoder.label = "Output Encoder"
        
        let outputPipeline = repository.createOrGetShader("identity") {
            self.createPostRenderPipelineState("identity")
        }
        
        outputEncoder.setRenderPipelineState(outputPipeline)
        
        outputEncoder.setFragmentTexture(input, index: 0)
        outputEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        outputEncoder.endEncoding()
    }
    
    private func drawFrame(on output: MTLDrawable, _ block: (MTLCommandBuffer) -> Void) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("Failed to create a command new command buffer.")
        }
        
        block(commandBuffer)

        commandBuffer.present(output)
        commandBuffer.commit()
    }
    
    private func createRenderPipelineState(_ shader: String) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "\(shader) Render Pipeline"
        
        descriptor.vertexFunction = library.makeFunction(name: "vertex_\(shader)")
        descriptor.fragmentFunction = library.makeFunction(name: "fragment_\(shader)")

        descriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        descriptor.depthAttachmentPixelFormat = depthStencilPixelFormat
        descriptor.stencilAttachmentPixelFormat = .invalid
        
        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func createPostRenderPipelineState(_ shader: String) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "Post Processing (\(shader)) Render Pipeline"
        
        descriptor.vertexFunction = library.makeFunction(name: "vertex_post")
        descriptor.fragmentFunction = library.makeFunction(name: "fragment_post_\(shader)")

        descriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        descriptor.depthAttachmentPixelFormat = .invalid
        descriptor.stencilAttachmentPixelFormat = .invalid
        
        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
