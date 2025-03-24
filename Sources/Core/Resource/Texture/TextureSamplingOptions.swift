import simd

public struct TextureSamplingOptions {
    public let tiling: simd_float2
    public let offset: simd_float2
    
    public init(
        tiling: simd_float2 = .init(1, 1),
        offset: simd_float2 = .init(0, 0)
    ) {
        self.tiling = tiling
        self.offset = offset
    }
}
