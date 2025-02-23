import MetalKit
import XEngineCore

public class MetalResourceRepository: ResourceRepository {
    var shaders: [String: MTLRenderPipelineState] = [:]
    var materials: [String: Material] = [:]
    var meshes: [String: MetalMesh] = [:]
    var textures: [String: MTLTexture] = [:]
    
    let textureLoader: MTKTextureLoader

    weak var device: MTLDevice?
    
    init(device: MTLDevice) {
        self.device = device
        self.textureLoader = MTKTextureLoader(device: device)
    }
    
    public func meshExists(name: String) -> Bool {
        meshes[name] != nil
    }
    
    public func materialExists(name: String) -> Bool {
        materials[name] != nil
    }

    public func textureExists(name: String) -> Bool {
        textures[name] != nil
    }

    public func registerMesh(_ name: String, mesh: Mesh) {
        guard let device = device else {
            return
        }
        
        meshes[name] = MetalMesh(device: device, mesh: mesh)
    }
    
    public func registerTexture(_ name: String, url: URL) {
        guard let device = device else {
            return
        }
        
        guard let texture = try? textureLoader.newTexture(URL: url, options: nil) else {
            return
        }
        
        textures[name] = texture
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
