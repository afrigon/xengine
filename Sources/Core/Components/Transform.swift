import simd

public class Transform {
    weak var parent: GameObject?
    
    public private(set) var position: simd_float3
    public private(set) var rotation: simd_quatf
    public private(set) var scale: simd_float3
    public private(set) var matrix: simd_float4x4
    
    public init(
        _ x: Float = 0,
        _ y: Float = 0,
        _ z: Float = 0,
        scale s: Float = 1
    ) {
        self.position = .init(x, y, z)
        self.rotation = .init(vector: .init(0, 0, 0, 1))
        self.scale = .init(s, s, s)
        
        self.matrix = Transformation.from(
            position: position,
            rotation: rotation,
            scale: scale
        )
    }
    
    public init(
        position: simd_float3 = .init(0, 0, 0),
        rotation: simd_quatf = .init(vector: .init(0, 0, 0, 1)),
        scale: simd_float3 = .init(1, 1, 1)
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
    
    public init(_ matrix: simd_float4x4) {
        self.position = .init(
            matrix.columns.3.x,
            matrix.columns.3.y,
            matrix.columns.3.z
        )

        self.scale = .init(
            simd_length(matrix.columns.0),
            simd_length(matrix.columns.1),
            simd_length(matrix.columns.2)
        )
        
        let rotationMatrix = simd_float3x3(rows: [
            .init(matrix.columns.0.x, matrix.columns.0.y, matrix.columns.0.z) / scale.x,
            .init(matrix.columns.1.x, matrix.columns.1.y, matrix.columns.1.z) / scale.y,
            .init(matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z) / scale.z
        ])
        
        self.rotation = simd_quatf(rotationMatrix)
        self.matrix = matrix
    }
    
    private func updateMatrix() {
        matrix = Transformation.from(
            position: position,
            rotation: rotation,
            scale: scale
        )
    }
    
    // TODO: when setting anything in this component maybe all the game objects children should be updated as well
    public func set(position: simd_float3) {
        self.position = position
        updateMatrix()
    }
    
    public func set(position x: Float, _ y: Float, _ z: Float) {
        set(position: .init(x, y, z))
    }

    public func set(rotation: simd_quatf) {
        self.rotation = rotation
        updateMatrix()
    }
    
    public func set(scale: simd_float3) {
        self.scale = scale
        updateMatrix()
    }
    
    public func set(scale x: Float, _ y: Float, _ z: Float) {
        set(scale: .init(x, y, z))
    }
    
    public func set(_ matrix: simd_float4x4) {
        self.position = .init(
            matrix.columns.3.x,
            matrix.columns.3.y,
            matrix.columns.3.z
        )

        self.scale = .init(
            simd_length(matrix.columns.0),
            simd_length(matrix.columns.1),
            simd_length(matrix.columns.2)
        )
        
        let rotationMatrix = simd_float3x3(rows: [
            .init(matrix.columns.0.x, matrix.columns.0.y, matrix.columns.0.z) / scale.x,
            .init(matrix.columns.1.x, matrix.columns.1.y, matrix.columns.1.z) / scale.y,
            .init(matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z) / scale.z
        ])
        
        self.rotation = simd_quatf(rotationMatrix)
        self.matrix = matrix
    }

    public func look(at target: Transform, up: simd_float3 = .up) {
        let forward = simd_normalize(target.position - position)
        let right = simd_normalize(simd_cross(up, forward))
        let up = simd_cross(forward, right)
        
        let rotation = simd_float3x3(right, up, forward)
        set(rotation: simd_quatf(rotation))
    }
}
