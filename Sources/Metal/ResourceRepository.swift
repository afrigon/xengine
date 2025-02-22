import Metal
import XEngineCore

public class ResourceRepository {
    var shaders: [String: MTLRenderPipelineState] = [:]
    var materials: [String: Material] = [:]
    var meshes: [String: MetalMesh] = [:]
    
    weak var device: MTLDevice?
    
    init(device: MTLDevice) {
        self.device = device
    }

    public func registerMesh(_ name: String, mesh: Mesh) {
        guard let device = device else {
            return
        }
        
        meshes[name] = MetalMesh(device: device, mesh: mesh)
    }

    public func registerMaterial(_ name: String, material: Material) {
        materials[name] = material
    }

    func getShaderIdentifier(for material: String, type: RendererType) -> String {
        materials[material]?.options.shader(type: type) ?? "unknown"
    }

    func createOrGetShader(_ identifier: String, _ generator: @escaping () -> MTLRenderPipelineState) -> MTLRenderPipelineState {
        if let shader = shaders[identifier] {
            return shader
        }
        
        let shader = generator()
        shaders[identifier] = shader
        
        return shader
    }
}
