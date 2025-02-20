import Foundation

extension Mesh {
    public static var cube: Mesh {
        let vertices: [SIMD3<Float>] = [
            // Front face
            .init(-0.5,  0.5, -0.5),  // 0
            .init( 0.5,  0.5, -0.5),  // 1
            .init( 0.5, -0.5, -0.5),  // 2
            .init(-0.5, -0.5, -0.5),  // 3
            
            // Left face
            .init(-0.5,  0.5,  0.5),  // 4
            .init(-0.5,  0.5, -0.5),  // 5
            .init(-0.5, -0.5, -0.5),  // 6
            .init(-0.5, -0.5,  0.5),  // 7
            
            // Back face
            .init( 0.5,  0.5,  0.5),  // 8
            .init(-0.5,  0.5,  0.5),  // 9
            .init(-0.5, -0.5,  0.5),  // 10
            .init( 0.5, -0.5,  0.5),  // 11
            
            // Right face
            .init( 0.5,  0.5, -0.5),  // 12
            .init( 0.5,  0.5,  0.5),  // 13
            .init( 0.5, -0.5,  0.5),  // 14
            .init( 0.5, -0.5, -0.5),  // 15
            
            // Top face
            .init(-0.5,  0.5,  0.5),  // 16
            .init( 0.5,  0.5,  0.5),  // 17
            .init( 0.5,  0.5, -0.5),  // 18
            .init(-0.5,  0.5, -0.5),  // 19
            
            // Bottom face
            .init( 0.5, -0.5,  0.5),  // 20
            .init(-0.5, -0.5,  0.5),  // 21
            .init(-0.5, -0.5, -0.5),  // 22
            .init( 0.5, -0.5, -0.5)   // 23
        ]
        
        let uv: [SIMD2<Float>] = [
            // Front face
            .init(0.0, 0.0),
            .init(1.0, 0.0),
            .init(1.0, 1.0),
            .init(0.0, 1.0),
            
            // Left face
            .init(0.0, 0.0),
            .init(1.0, 0.0),
            .init(1.0, 1.0),
            .init(0.0, 1.0),
            
            // Back face
            .init(0.0, 0.0),
            .init(1.0, 0.0),
            .init(1.0, 1.0),
            .init(0.0, 1.0),
            
            // Right face
            .init(0.0, 0.0),
            .init(1.0, 0.0),
            .init(1.0, 1.0),
            .init(0.0, 1.0),
            
            // Top face
            .init(0.0, 0.0),
            .init(1.0, 0.0),
            .init(1.0, 1.0),
            .init(0.0, 1.0),
            
            // Bottom face
            .init(0.0, 0.0),
            .init(1.0, 0.0),
            .init(1.0, 1.0),
            .init(0.0, 1.0)
        ]
        
        let indices: [UInt32] = [
            // Front face
            0, 1, 2, 0, 2, 3,
            
            // Left face
            4, 5, 6, 4, 6, 7,
            
            // Back face
            8, 9, 10, 8, 10, 11,
            
            // Right face
            12, 13, 14, 12, 14, 15,
            
            // Top face
            16, 17, 18, 16, 18, 19,
            
            // Bottom face
            20, 21, 22, 20, 22, 23
        ]
        
        let normals: [SIMD3<Float>] = [
            // Front face
            .init(0, 0, -1),
            .init(0, 0, -1),
            .init(0, 0, -1),
            .init(0, 0, -1),
            
            // Left face
            .init(-1, 0, 0),
            .init(-1, 0, 0),
            .init(-1, 0, 0),
            .init(-1, 0, 0),
            
            // Back face
            .init(0, 0, 1),
            .init(0, 0, 1),
            .init(0, 0, 1),
            .init(0, 0, 1),
            
            // Right face
            .init(1, 0, 0),
            .init(1, 0, 0),
            .init(1, 0, 0),
            .init(1, 0, 0),
            
            // Top face
            .init(0, 1, 0),
            .init(0, 1, 0),
            .init(0, 1, 0),
            .init(0, 1, 0),
            
            // Bottom face
            .init(0, -1, 0),
            .init(0, -1, 0),
            .init(0, -1, 0),
            .init(0, -1, 0)
        ]
        
        let tangents: [SIMD3<Float>] = [
            // Front face
            .init(1.0, 0.0, 0.0),
            .init(1.0, 0.0, 0.0),
            .init(1.0, 0.0, 0.0),
            .init(1.0, 0.0, 0.0),
            
            // Left face
            .init(0.0, 0.0, -1.0),
            .init(0.0, 0.0, -1.0),
            .init(0.0, 0.0, -1.0),
            .init(0.0, 0.0, -1.0),
            
            // Back face
            .init(-1.0, 0.0, 0.0),
            .init(-1.0, 0.0, 0.0),
            .init(-1.0, 0.0, 0.0),
            .init(-1.0, 0.0, 0.0),
            
            // Right face
            .init(0.0, 0.0, 1.0),
            .init(0.0, 0.0, 1.0),
            .init(0.0, 0.0, 1.0),
            .init(0.0, 0.0, 1.0),

            // Top face
            .init(1.0, 0.0, 0.0),
            .init(1.0, 0.0, 0.0),
            .init(1.0, 0.0, 0.0),
            .init(1.0, 0.0, 0.0),
            
            // Bottom face
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
