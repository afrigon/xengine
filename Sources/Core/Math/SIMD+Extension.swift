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
