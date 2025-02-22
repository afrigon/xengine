import simd

public enum Projection {
    case perspective(
        fov: Angle = .degrees(90),
        aspect: Float = 1,
        near: Float = 0.05,
        far: Float = 1000,
        handedness: Handedness = .leftHand
    )
    
    public var matrix: simd_float4x4 {
        switch self {
            case let .perspective(fov, aspect, near, far, orientation):
                let ys = 1 / tanf(fov.radians * 0.5)
                let xs = ys / aspect
                
                switch orientation {
                    case .leftHand:
                        let zs = far / (far - near)
                        
                        return simd_float4x4(rows: [
                            .init(xs,  0,  0,          0),
                            .init( 0, ys,  0,          0),
                            .init( 0,  0, zs, -near * zs),
                            .init( 0,  0,  1,          0)
                        ])
                    case .rightHand:
                        let zs = (far + near) / (near - far)
                        
                        return simd_float4x4(rows: [
                            .init(xs,  0,  0,         0),
                            .init( 0, ys,  0,         0),
                            .init( 0,  0, zs, near * zs), // TODO: chatgipiti told me to double check this
                            .init( 0,  0, -1,         0)
                        ])
                }
        }
    }
}
