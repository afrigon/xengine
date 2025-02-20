import simd

public class Transform {
    public var position: SIMD3<Float> {
        didSet {
            matrix = generateMatrix()
        }
    }
    
    public var rotation: SIMD3<Float> {
        didSet {
            matrix = generateMatrix()
        }
    }
    
    public var scale: SIMD3<Float> {
        didSet {
            matrix = generateMatrix()
        }
    }
    
    public private(set) var matrix: simd_float4x4
    public var matrix3x3: simd_float3x3 {
        let column0 = matrix.columns.0
        let column1 = matrix.columns.1
        let column2 = matrix.columns.2
        
        return simd_float3x3(columns: (
            simd_float3(column0.x, column1.x, column2.x),
            simd_float3(column0.y, column1.y, column2.y),
            simd_float3(column0.z, column1.z, column2.z)
        ))
    }
    
    private func generateMatrix() -> simd_float4x4 {
        Transformation.from(
            position: position,
            rotation: rotation,
            scale: scale
        )
    }
    
    public init(_ x: Float = 0, _ y: Float = 0, _ z: Float = 0, scale: Float = 1) {
        self.position = .init(x, y, z)
        self.rotation = .init(0, 0, 0)
        self.scale = .init(scale, scale, scale)
        self.matrix = Transformation.from(
            position: position,
            rotation: rotation,
            scale: self.scale
        )
    }
    
    public init(
        position: SIMD3<Float> = .init(0, 0, 0),
        rotation: SIMD3<Float> = .init(0, 0, 0),
        scale: SIMD3<Float> = .init(1, 1, 1)
    ) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
        self.matrix = Transformation.from(
            position: position,
            rotation: rotation,
            scale: scale
        )
    }
}
