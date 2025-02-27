import simd

public enum Projection {
    case perspective(
        fov: Angle = .degrees(80),
        aspect: Float = 1,
        near: Float = 0.05,
        far: Float = 1000
    )
    
    public func resized(width: UInt32, height: UInt32) -> Projection {
        switch self {
            case .perspective(let fov, let aspect, let near, let far):
                .perspective(fov: fov, aspect: Float(width) / Float(height), near: near, far: far)
        }
    }
    
    public var matrix: simd_float4x4 {
        switch self {
            case let .perspective(fov, aspect, near, far):
                let ys = 1 / tanf(fov.radians * 0.5)
                let xs = ys / aspect
                let zs = far / (far - near)
                
                return simd_float4x4(rows: [
                    .init(xs,  0,  0,          0),
                    .init( 0, ys,  0,          0),
                    .init( 0,  0, zs, -near * zs),
                    .init( 0,  0,  1,          0)
                ])
        }
    }
}
