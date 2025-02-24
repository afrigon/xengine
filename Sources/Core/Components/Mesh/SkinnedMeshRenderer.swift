public class SkinnedMeshRenderer: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Skinned Mesh Renderer"
    }
    
    public let mesh: String
    public var material: String
    
    weak public var rootBone: Bone?

    public init(
        mesh: String,
        material: String,
        rootBone: Bone
    ) {
        self.mesh = mesh
        self.material = material
        self.rootBone = rootBone
    }
    
    public func update(input: Input, delta: Float) { }
}
