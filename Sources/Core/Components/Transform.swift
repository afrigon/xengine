import simd

public class Transform {
    weak var parent: GameObject?
    
    public var position: simd_float3 {
        get {
            .init(
                matrix.columns.3.x,
                matrix.columns.3.y,
                matrix.columns.3.z
            )
        }
        set {
            matrix = Transformation.from(
                position: newValue,
                rotation: rotation,
                scale: scale
            )
        }
    }
    
    public var rotation: simd_quatf {
        get {
            let column0 = simd_float3(matrix.columns.0.x, matrix.columns.0.y, matrix.columns.0.z)
            let column1 = simd_float3(matrix.columns.1.x, matrix.columns.1.y, matrix.columns.1.z)
            let column2 = simd_float3(matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z)
            
            let rotationMatrix = simd_float3x3(columns: (
                simd_normalize(column0),
                simd_normalize(column1),
                simd_normalize(column2)
            ))
            
            return simd_quatf(rotationMatrix)
        }
        set {
            matrix = Transformation.from(
                position: position,
                rotation: newValue,
                scale: scale
            )
        }
    }
    
    public var scale: simd_float3 {
        get {
            .init(
                simd_length(matrix.columns.0),
                simd_length(matrix.columns.1),
                simd_length(matrix.columns.2)
            )
        }
        set {
            matrix = Transformation.from(
                position: position,
                rotation: rotation,
                scale: newValue
            )
        }
    }
    
    public var matrix: simd_float4x4 {
        get {
            _matrix
        }
        set {
            let old = _matrix
            _matrix = newValue
            
            propagate(from: old, to: _matrix)
        }
    }
    
    public var _matrix: simd_float4x4

    public init(
        position: simd_float3 = .init(0, 0, 0),
        rotation: simd_quatf = .init(vector: .init(0, 0, 0, 1)),
        scale: simd_float3 = .init(1, 1, 1)
    ) {
        _matrix = Transformation.from(
            position: position,
            rotation: rotation,
            scale: scale
        )
    }
    
    convenience public init(
        _ x: Float = 0,
        _ y: Float = 0,
        _ z: Float = 0,
        scale s: Float = 1
    ) {
        self.init(
            position: .init(x, y, z),
            scale: .init(s, s, s)
        )
    }

    public init(_ matrix: simd_float4x4) {
        _matrix = matrix
    }
    
    func propagate(from old: simd_float4x4, to new: simd_float4x4) {
        guard let parent else {
            return
        }
        
        for child in parent.children {
            let oldChildMatrix = child.transform.matrix
            let localChildMatrix = simd_inverse(old) * oldChildMatrix
            let newChildMatrix = new * localChildMatrix
            
            child.transform._matrix = newChildMatrix
            child.transform.propagate(from: oldChildMatrix, to: newChildMatrix)
        }
    }

    public func look(at target: Transform, up: simd_float3 = .up) {
        let forward = simd_normalize(target.position - position)
        let right = simd_normalize(simd_cross(up, forward))
        let up = simd_cross(forward, right)
        
        let rotation = simd_float3x3(right, up, forward)
        self.rotation = simd_quatf(rotation)
    }
}
