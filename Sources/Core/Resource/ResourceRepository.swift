import Foundation

public protocol ResourceRepository {
    func meshExists(name: String) -> Bool
    func materialExists(name: String) -> Bool
    func textureExists(name: String) -> Bool
    
    func registerMesh(_ name: String, mesh: Mesh)
    func registerMaterial(_ name: String, material: Material)
    func registerTexture(_ name: String, url: URL)
}
