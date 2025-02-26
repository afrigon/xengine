import simd

public class Bone: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Bone"
    }
    
    let boneName: String
    
    /// bone transform in model space before animation.
    let bindTransform: simd_float4x4
    
    /// inverse of the bind transform (model to local space).
    let inverseBindTransform: simd_float4x4

    /// transform to apply to this bone in local space.
    var animationTransform: simd_float4x4 = .init(diagonal: .init(repeating: 1))
    
    /// bone transform in model space after animation.
    var poseTransform: simd_float4x4
    
    /// transform needed to go from bind to animated pose, applied to vertices.
    internal(set) public var finalTransform: simd_float4x4 = .init(diagonal: .one)

    public init(name: String, bindTransform: simd_float4x4) {
        self.boneName = name
        self.bindTransform = bindTransform
        self.inverseBindTransform = bindTransform.inverse
        self.poseTransform = bindTransform
    }
    
    public func update(input: Input, delta: Float) { }
}
