import XEngineCore
import MetalKit

class MetalRenderer {
    private(set) var repository: MetalResourceRepository
    
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
    
    @MainActor
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
    
    @MainActor
    func draw(scene: GameScene, globals: Globals, in view: MTKView, debug: DebugOptions) {
        // resources management load / clean
        // ideas: ref count + periodic purge if above memory quota
        // for the pokemon project all asset should fit into ram without any problem
        
        // TODO: add some rate limiting semaphore thing?? research why I had that in the other project
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        drawFrame(on: drawable) { commandBuffer in
            guard let sceneTexture = drawScene(scene: scene, globals: globals, debug: debug, commandBuffer: commandBuffer) else {
                return
            }
            
            let processed = drawPost(
                from: sceneTexture,
                effects: scene.camera.postProcessing.effects,
                deltaTime: globals.deltaTime,
                commandBuffer: commandBuffer
            )
            
            // this is where UI element would be rendered but it is not supported yet.
            // The intended way of doing UI is to layer SwiftUI on top of the MetalView.
            
            // TODO: instead of drawing an identity post processing to the final display. the last layer of post processing should be drawn to the screen.
            drawOutput(from: processed, to: drawable.texture, commandBuffer: commandBuffer)
        }
    }
    
    private func drawScene(scene: GameScene, globals: Globals, debug: DebugOptions, commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        sceneRenderTarget.setClearColor(scene.camera.clear)
        
        guard let descriptor = sceneRenderTarget.renderPassDescriptor,
              let sceneEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Failed to make render command encoder.")
        }
        
        sceneEncoder.label = "Scene Encoder"

        sceneEncoder.setDepthStencilState(depthStencilState)
        sceneEncoder.setTriangleFillMode(debug.wireframe ? .lines : .fill)
        
        var globals = globals
        
        // TODO: filter lights based on distance / other euristics
        let lights = scene.query(component: Light.self)
        
        let directionalLights: [DirectionalLight] = lights
            .compactMap { (light) -> DirectionalLight? in
                guard case let .directional(options) = light.options else {
                    return nil
                }
                
                return .init(
                    direction: simd_normalize(simd_float3(
                        light.transform.rotation.x,
                        light.transform.rotation.y,
                        -light.transform.rotation.z
                    )),
                    color: options.color.rgb,
                    intensity: options.intensity
                )
            }
            
        let jobs: [RenderJob] = (scene
            .query(component: MeshRenderer.self)
            .map {
                .basic(
                    mode: repository.materials[$0.material]?.commonOptions.renderingMode ?? .opaque,
                    shader: repository.getShaderIdentifier(for: $0.material),
                    renderer: $0
                )
            } +
        scene
            .query(component: SkinnedMeshRenderer.self)
            .map {
                .skinned(
                    mode: repository.materials[$0.material]?.commonOptions.renderingMode ?? .opaque,
                    shader: repository.getShaderIdentifier(for: $0.material),
                    renderer: $0
                )
            }
        )
        .sorted()
        
        // TODO: filter visible objects
        
        var shaderCache: String? = nil
        var materialCache: String? = nil
        var meshCache: String? = nil

        var pipeline: MTLRenderPipelineState? = nil
        var material: Material? = nil
        var mesh: MetalMesh? = nil

        for job in jobs {
            let currentMaterial = debug.materialOverride ?? job.material
            let currentShader = debug.materialOverride.map {
                repository.getShaderIdentifier(for: $0)
            } ?? job.shader
            
            if shaderCache != currentShader {
                pipeline = repository.createOrGetShader(currentShader) {
                    self.createRenderPipelineState(currentShader, type: job.type)
                }
                
                sceneEncoder.setRenderPipelineState(pipeline!)
                
                shaderCache = job.shader
            }
            
            if materialCache != currentMaterial {
                material = repository.materials[currentMaterial]

                if let material {
                    sceneEncoder.setCullMode(material.commonOptions.cullingMode.metal)
                    sceneEncoder.setFrontFacing(material.commonOptions.frontFacing.metal)
                    sceneEncoder.setDepthBias(material.commonOptions.depthBias ? 0.001 : 0, slopeScale: 1, clamp: 0)

                    switch material.options {
                        case .unlitColor(let m):
                            sceneEncoder.setFragmentBytes([m.color], length: MemoryLayout.size(ofValue: m.color), index: 1)
                        case .blinnPhong(let m):
                            let data = BlinnPhongData(
                                directionalLightCount: UInt32(directionalLights.count),
                                useAlbedoTexture: m.useAlbedoTexture,
                                albedoColor: m.albedoColor.rgb,
                                alphaCutoff: material.commonOptions.renderingMode.alphaCutoff
                            )
                            sceneEncoder.setFragmentBytes([data], length: MemoryLayout<BlinnPhongData>.stride, index: 1)
                            
                            if !directionalLights.isEmpty {
                                sceneEncoder.setFragmentBytes(directionalLights, length: MemoryLayout<DirectionalLight>.stride * directionalLights.count, index: 2)
                            }
                            
                            if let albedoId = m.albedo, let albedo = repository.textures[albedoId] {
                                sceneEncoder.setFragmentTexture(albedo, index: 3)
                            }
                        case .normals:
                            break
                    }
                }
                
                materialCache = job.material
            }
            
            if meshCache != job.mesh {
                mesh = repository.meshes[job.mesh]
                
                if let mesh {
                    sceneEncoder.setVertexBuffer(mesh.verticesBuffer, index: 1)
                    sceneEncoder.setVertexBuffer(mesh.normalsBuffer, index: 2)
                    sceneEncoder.setVertexBuffer(mesh.tangentsBuffer, index: 3)
                    sceneEncoder.setVertexBuffer(mesh.uv0Buffer, index: 4)
                    
                    if case .skinned(_, _, let renderer) = job {
                        guard let boneIndices = mesh.boneIndicesBuffer else {
                            continue
                        }
                        
                        sceneEncoder.setVertexBuffer(boneIndices, index: 5)
                    }
                    
                    meshCache = job.mesh
                }
            }
            
            if let mesh {
                switch job {
                    case .basic(_, _, let renderer):
                        globals.modelMatrix = renderer.transform.matrix
                        globals.modelViewProjectionMatrix = scene.camera.viewProjectionMatrix * globals.modelMatrix
                        globals.normalMatrix = simd_transpose(simd_inverse(globals.modelMatrix.matrix3x3))
                    case .skinned(_, _, let renderer):
                        globals.modelMatrix = renderer.transform.matrix
                        globals.modelViewProjectionMatrix = scene.camera.viewProjectionMatrix * globals.modelMatrix
                        globals.normalMatrix = simd_transpose(simd_inverse(globals.modelMatrix.matrix3x3))
                        
                        let bones = renderer.parent?
                            .query(component: Bone.self)
                            .compactMap { $0.animationTransform.matrix }
                        
                        guard let bones, let boneBuffer = device.makeBuffer(length: MemoryLayout<simd_float4x4>.stride * bones.count) else {
                            break  // TODO: investigate if this crashes when hit, maybe just continue instead
                        }
                        
                        boneBuffer.contents().copyMemory(from: bones, byteCount: MemoryLayout<simd_float4x4>.stride * bones.count)
                        
                        sceneEncoder.setVertexBuffer(boneBuffer, index: 6)
                }

                sceneEncoder.setVertexBytes(
                    [globals],
                    length: MemoryLayout<Globals>.stride,
                    index: 0
                )
                
                sceneEncoder.setFragmentBytes(
                    [globals],
                    length: MemoryLayout<Globals>.stride,
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
    
    private func drawPost(from input: MTLTexture, effects: [PostProcessingEffect], deltaTime: Float, commandBuffer: MTLCommandBuffer) -> MTLTexture {
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
                postEncoder: encoder,
                deltaTime: deltaTime
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
        postEncoder: MTLRenderCommandEncoder,
        deltaTime: Float
    ) {
        let pipeline = repository.createOrGetShader(effect.shader) {
            self.createPostRenderPipelineState(effect.shader)
        }
        
        postEncoder.setRenderPipelineState(pipeline)
        
        postEncoder.setFragmentTexture(input, index: 0)
        
        if effect.needsDepthTexture {
            postEncoder.setFragmentTexture(sceneRenderTarget.depthTexture, index: 1)
        }
        
        if effect.needsTime {
            postEncoder.setFragmentBytes([deltaTime], length: MemoryLayout.size(ofValue: deltaTime), index: 2)
        }

        switch effect {
            case .fxaa(let options):
                postEncoder.setFragmentBytes([options], length: MemoryLayout.size(ofValue: options), index: 3)
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
    
    private func createRenderPipelineState(_ shader: String, type: String) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "\(shader) Render Pipeline"
        
        descriptor.vertexFunction = library.makeFunction(name: "vertex_\(type)")
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
        
        descriptor.vertexFunction = library.makeFunction(name: "vertex_quad")
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
