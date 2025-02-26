/// - note: the `SkinnedMeshRenderer` assumes it is attached to the game object with the root bone.
public class SkinnedMeshRenderer: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Skinned Mesh Renderer"
    }
    
    public let mesh: String
    public var material: String

    public init(
        mesh: String,
        material: String
    ) {
        self.mesh = mesh
        self.material = material
    }
    
    public func update(input: Input, delta: Float) { }
}
