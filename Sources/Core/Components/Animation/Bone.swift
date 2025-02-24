import simd

public class Bone: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Bone"
    }
    
    public var baseTransform: Transform
    public var animationTransform: Transform = .init()
    public var finalTransform: simd_float4x4 = .init()

    public init(_ transform: Transform) {
        self.baseTransform = transform
    }
    
    public func update(input: Input, delta: Float) { }
}
