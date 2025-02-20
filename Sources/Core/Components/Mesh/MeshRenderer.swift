import Foundation

public class MeshRenderer: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String { 
        "Mesh Renderer"
    }
    
    public let mesh: String
    public let material: String
    
    public init(
        mesh: String,
        material: String
    ) {
        self.mesh = mesh
        self.material = material
    }
    
    public func update(input: Input, delta: Double) { }
}
