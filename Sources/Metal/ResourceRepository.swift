import Metal
import XEngineCore

public class ResourceRepository {
    var shaders: [String: MTLRenderPipelineState] = [:]
    var materials: [String: Material] = [:]
    var meshes: [String: MetalMesh] = [:]

    func getShaderIdentifier(for material: String, type: RendererType) -> String {
        materials[material]?.shader(type: type) ?? "unknown"
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
