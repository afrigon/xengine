import simd

public struct Transformation {
    public static func from(
        position: SIMD3<Float>,
        rotation: SIMD3<Float>,
        scale: SIMD3<Float>
    ) -> simd_float4x4 {
        Transformation.translate(position) *
        Transformation.rotate(rotation) *
        Transformation.scale(scale)
    }
    
    public static func translate(_ x: Float, _ y: Float, _ z: Float) -> simd_float4x4 {
        simd_float4x4(rows: [
            .init(1, 0, 0, x),
            .init(0, 1, 0, y),
            .init(0, 0, 1, z),
            .init(0, 0, 0, 1)
        ])
    }
    
    public static func translate(_ t: SIMD3<Float>) -> simd_float4x4 {
        Transformation.translate(t.x, t.y, t.z)
    }
    
    public static func scale(_ x: Float, _ y: Float, _ z: Float) -> simd_float4x4 {
        simd_float4x4(rows: [
            .init(x, 0, 0, 0),
            .init(0, y, 0, 0),
            .init(0, 0, z, 0),
            .init(0, 0, 0, 1)
        ])
    }
    
    public static func scale(_ s: SIMD3<Float>) -> simd_float4x4 {
        Transformation.scale(s.x, s.y, s.z)
    }
    
    /// - Parameter x: pitch angle in degrees
    /// - Parameter y: yaw angle in degrees
    /// - Parameter z: roll angle in degrees
    public static func rotate(_ x: Float, _ y: Float, _ z: Float) -> simd_float4x4 {
        let sx = sinf(Angle.degrees(x).radians)
        let cx = cosf(Angle.degrees(x).radians)
        let sy = sinf(Angle.degrees(y).radians)
        let cy = cosf(Angle.degrees(y).radians)
        let sz = sinf(Angle.degrees(z).radians)
        let cz = cosf(Angle.degrees(z).radians)
        
        return simd_float4x4(rows: [
            .init(cy * cz, sx * sy * cz - cx * sz, cx * sy * cz + sx * sz, 0),
            .init(cy * sz, sx * sy * sz + cx * cz, cx * sy * sz - sx * cz, 0),
            .init(    -sy,                sx * cy,                cx * cy, 0),
            .init(      0,                      0,                      0, 1)
        ])
    }
    
    public static func rotate(_ r: SIMD3<Float>) -> simd_float4x4 {
        Transformation.rotate(r.x, r.y, r.z)
    }
}
