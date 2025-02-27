import simd

extension simd_float4x4 {
    public var matrix3x3: simd_float3x3 {
        .init(columns: (
            simd_float3(columns.0.x, columns.0.y, columns.0.z),
            simd_float3(columns.1.x, columns.1.y, columns.1.z),
            simd_float3(columns.2.x, columns.2.y, columns.2.z)
        ))
    }
}

extension simd_half4x4 {
    public var matrix3x3: simd_half3x3 {
        .init(columns: (
            simd_half3(columns.0.x, columns.0.y, columns.0.z),
            simd_half3(columns.1.x, columns.1.y, columns.1.z),
            simd_half3(columns.2.x, columns.2.y, columns.2.z)
        ))
    }
}

extension simd_quatf {
    public var eulerAngles: simd_float3 {
        let forward = act(.forward)
        
        let pitch = asin(min(1, max(-1, forward.y)))
        let yaw = atan2(forward.x, -forward.z)
        let up = act(.up)
        let roll = atan2(up.x, up.y)
        
        return simd_float3(
            Angle(radians: pitch).degrees,
            Angle(radians: yaw).degrees,
            Angle(radians: roll).degrees
        )
    }
}

extension simd_float3 {
    public static var up: simd_float3 { .init(0, 1, 0) }
    public static var down: simd_float3 { .init(0, -1, 0) }
    public static var left: simd_float3 { .init(-1, 0, 0) }
    public static var right: simd_float3 { .init(1, 0, 0) }
    public static var forward: simd_float3 { .init(0, 0, 1) }
    public static var backward: simd_float3 { .init(0, 0, -1) }
}
