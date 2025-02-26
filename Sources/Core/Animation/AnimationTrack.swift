import simd

public struct AnimationTrack {
    let position: KeyframeTimeline<simd_float3>
    let rotation: KeyframeTimeline<simd_quatf>
    let scale: KeyframeTimeline<simd_float3>
    
    public init(
        position: KeyframeTimeline<simd_float3>,
        rotation: KeyframeTimeline<simd_quatf>,
        scale: KeyframeTimeline<simd_float3>
    ) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
    
    func transform(at time: Float) -> simd_float4x4 {
        let p = position.value(at: time, interpolator: lerp) ?? .zero
        let r = rotation.value(at: time, interpolator: simd_slerp) ?? .init(vector: .init(0, 0, 0, 1))
        let s = scale.value(at: time, interpolator: lerp) ?? .one
        
        return Transformation.from(position: p, rotation: r, scale: s)
    }
    
    private func lerp(a: simd_float3, b: simd_float3, t: Float) -> simd_float3 {
        .init(
            lerp(a: a.x, b: b.x, t: t),
            lerp(a: a.y, b: b.y, t: t),
            lerp(a: a.z, b: b.z, t: t)
        )
    }
    
    private func lerp(a: Float, b: Float, t: Float) -> Float {
        a + (b - a) * t
    }
}
