import simd

public class AnimationController {
    var animationTime: Float = 0.0
    
    // TODO: implement AnimationClip transitions
    var current: String = ""
    
    let clips: [String: AnimationClip]
    
    public init(clips: [String: AnimationClip]) {
        self.clips = clips
    }
    
    public func set(current: String) {
        self.current = current
        self.animationTime = 0
    }
    
    func transform(for bone: String) -> simd_float4x4 {
        clips[current]?.tracks[bone]?.transform(at: animationTime) ?? .init(diagonal: .one)
    }
    
    func update(delta: Float) {
        animationTime += delta
    }
}
