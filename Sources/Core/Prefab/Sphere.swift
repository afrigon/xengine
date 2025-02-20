import Foundation

extension Mesh {
    public static func sphere(resolution: Int = 20) -> Mesh {
        sphere(horizontalResolution: resolution, verticalResolution: resolution)
    }
    
    public static func sphere(horizontalResolution: Int = 20, verticalResolution: Int = 20) -> Mesh {
        var vertices: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var tangents: [SIMD3<Float>] = []
        var uv: [SIMD2<Float>] = []
        
        for i in 0..<horizontalResolution {
            for j in 0..<verticalResolution {
                let u = Float(i) / Float(horizontalResolution - 1)
                let v = Float(j) / Float(verticalResolution - 1)
                
                let theta = u * 2 * .pi
                let phi = v * .pi
                
                vertices.append(.init(
                    0.5 * sin(phi) * cos(theta),
                    0.5 * sin(phi) * sin(theta),
                    0.5 * cos(phi)
                ))
                
                uv.append(.init(u, v))
                
                tangents.append(.init(
                    -sin(theta),
                     cos(theta),
                     0.0
                ))
            }
        }
        
        for i in 0..<horizontalResolution - 1 {
            for j in 0..<verticalResolution - 1 {
                let index0 = UInt32(j * horizontalResolution + i)
                let index1 = UInt32(j * horizontalResolution + i + 1)
                let index2 = UInt32((j + 1) * horizontalResolution + i)
                let index3 = UInt32((j + 1) * horizontalResolution + i + 1)
                
                indices.append(contentsOf: [
                    index1, index2, index0, index3, index2, index1
                ])
            }
        }
        
        return .init(
            vertices: vertices.withUnsafeBufferPointer { Data(buffer: $0) },
            indices: indices.withUnsafeBufferPointer { Data(buffer: $0) },
            normals: vertices.withUnsafeBufferPointer { Data(buffer: $0) },
            tangents: tangents.withUnsafeBufferPointer { Data(buffer: $0) },
            uv: uv.withUnsafeBufferPointer { Data(buffer: $0) }
        )
    }
}
