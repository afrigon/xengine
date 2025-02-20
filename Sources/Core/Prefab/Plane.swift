import Foundation

extension Mesh {
    public static var plane: Mesh {
        let vertices: [SIMD3<Float>] = [
            .init(-0.5,  0.5, 0.0),  // 0
            .init( 0.5,  0.5, 0.0),  // 1
            .init( 0.5, -0.5, 0.0),  // 2
            .init(-0.5, -0.5, 0.0)   // 3
        ]
        
        let uv: [SIMD2<Float>] = [
            .init(0.0, 0.0),
            .init(1.0, 0.0),
            .init(1.0, 1.0),
            .init(0.0, 1.0)
        ]
        
        let indices: [UInt32] = [0, 1, 2, 0, 2, 3]
        
        let normals: [SIMD3<Float>] = [
            .init(0, 0, -1),
            .init(0, 0, -1),
            .init(0, 0, -1),
            .init(0, 0, -1)
        ]
        
        let tangents: [SIMD3<Float>] = [
            .init(1.0, 0.0, 0.0),
            .init(1.0, 0.0, 0.0),
            .init(1.0, 0.0, 0.0),
            .init(1.0, 0.0, 0.0)
        ]
        
        return .init(
            vertices: vertices.withUnsafeBufferPointer { Data(buffer: $0) },
            indices: indices.withUnsafeBufferPointer { Data(buffer: $0) },
            normals: normals.withUnsafeBufferPointer { Data(buffer: $0) },
            tangents: tangents.withUnsafeBufferPointer { Data(buffer: $0) },
            uv: uv.withUnsafeBufferPointer { Data(buffer: $0) }
        )
    }
}
