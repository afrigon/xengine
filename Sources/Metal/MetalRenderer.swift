import XEngineCore
import MetalKit

class MetalRenderer {
    private var repository: ResourceRepository = .init()
    
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

//    private var sceneRenderTarget: MetalRenderTarget
    private var outputRenderTarget: ScreenColorDepthRenderTarget


    init?() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = try? device.makeDefaultLibrary(bundle: Bundle.module),
              let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        
        self.device = device
        self.library = library
        self.commandQueue = commandQueue
        
//        self.sceneRenderTarget = .init(pixelFormat: colorPixelFormat)
        self.outputRenderTarget = ScreenColorDepthRenderTarget(colorFormat: colorPixelFormat, depthFormat: depthStencilPixelFormat)
    }
    
    func setup(with view: MTKView) {
        view.device = device
        view.colorPixelFormat = colorPixelFormat
        view.depthStencilPixelFormat = depthStencilPixelFormat
        
        outputRenderTarget.setup(
            width: Int(view.frame.width),
            height: Int(view.frame.height),
            device: device
        )
    }
    
    func resize(width: UInt32, height: UInt32) {
        outputRenderTarget.resize(width: Int(width), height: Int(height), device: device)
    }
    
    func draw(scene: GameScene, globals: Globals, in view: MTKView) {
        // resources management load / clean
        // ideas: ref count + periodic purge if above memory quota
        // for the pokemon project all asset should fit into ram without any problem
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        outputRenderTarget.set(color: drawable.texture)
        outputRenderTarget.set(depth: view.depthStencilTexture)
        outputRenderTarget.setClearColor(scene.camera.clear)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("Failed to create a command new command buffer.")
        }
        
        guard let descriptor = outputRenderTarget.renderPassDescriptor,
              let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Failed to make render command encoder.")
        }
        
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setCullMode(.back)
        renderCommandEncoder.setFrontFacing(.clockwise)
        
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
                
                renderCommandEncoder.setRenderPipelineState(pipeline!)

                lastShader = entry.identifier.shader
            }
            
            if lastMaterial != entry.identifier.material {
                // do material loading stuff + texture
                material = repository.materials[entry.identifier.material]
                
                if let material {
                    switch material {
                        case .unlitColor(let m):
                            renderCommandEncoder.setFragmentBytes([m.color], length: MemoryLayout.size(ofValue: m.color), index: 1)
                    }
                }
                
                lastMaterial = entry.identifier.material
            }
            
            if lastMesh != entry.identifier.mesh {
                mesh = repository.meshes[entry.identifier.mesh]
                
                renderCommandEncoder.setVertexBuffer(mesh!.verticesBuffer, index: 1)
                renderCommandEncoder.setVertexBuffer(mesh!.normalsBuffer, index: 2)
                renderCommandEncoder.setVertexBuffer(mesh!.tangentsBuffer, index: 3)
                renderCommandEncoder.setVertexBuffer(mesh!.uv0Buffer, index: 4)

                lastMesh = entry.identifier.mesh
            }
            
            if let mesh {
                globals.modelMatrix = entry.transform.matrix
                globals.modelViewProjectionMatrix = scene.camera.viewProjectionMatrix * entry.transform.matrix
                globals.normalMatrix = entry.transform.matrix3x3
                
                renderCommandEncoder.setVertexBytes(
                    [globals],
                    length: MemoryLayout.size(ofValue: globals),
                    index: 0
                )
                
                renderCommandEncoder.setFragmentBytes(
                    [globals],
                    length: MemoryLayout.size(ofValue: globals),
                    index: 0
                )

                renderCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: mesh.indicesCount,
                    indexType: .uint32,
                    indexBuffer: mesh.indicesBuffer,
                    indexBufferOffset: 0
                )
            }
        }
        
        renderCommandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func createRenderPipelineState(_ shader: String) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "\(shader) Render Pipeline"
        
        descriptor.vertexFunction = library.makeFunction(name: "vertex_\(shader)")
        descriptor.vertexFunction = library.makeFunction(name: "fragment_\(shader)")

        descriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        descriptor.depthAttachmentPixelFormat = depthStencilPixelFormat
        descriptor.stencilAttachmentPixelFormat = depthStencilPixelFormat
        
        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
