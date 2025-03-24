import Foundation
import XEngineCore
import simd
import XKit

public struct ObjectFileLoader {
    private enum ObjectFileInstruction {
        case object(String)
        case vertex(simd_float3)
        case normal(simd_float3)
        case uv(simd_float2)
        case face([(Int, Int, Int)])
        case line([(simd_float3, simd_float2)])
        case material(String)
        case useMaterial(String)
        case group(String)
        case smoothGroup(Int)
    }
    
    // TODO: add mtl file support.
    public static func load(
        _ url: URL,
        material: String = "default",  // only a single material is supported for now.
        repository: ResourceRepository
    ) -> GameObject? {
        // for the v1 of this loader we assume a triagulated model with UV and normal information.
        
        do {
            guard let data = String(data: try Data(contentsOf: url), encoding: .utf8) else {
                return nil
            }
            
            let lines = data.split(separator: "\n")
            
            let object = GameObject()
            object.name = url.absoluteString
            
            var meshIdentifier: String? = nil
            var vertices: [simd_float3] = []
            var normals: [simd_float3] = []
            var uvs: [simd_float2] = []
            var indices: [(Int, Int, Int)] = []
            var vertexOffset = 0
            var normalOffset = 0
            var uvOffset = 0

            for line in lines {
                let instruction = parse(line: line)
                
                switch instruction {
                    case .vertex(let vertex):
                        vertices.append(vertex)
                    case .normal(let normal):
                        normals.append(normal)
                    case .uv(let uv):
                        uvs.append(uv)
                    case .face(let face):
                        indices.append(contentsOf: face.map {
                            ($0.0 - vertexOffset, $0.1 - uvOffset, $0.2 - normalOffset)
                        })
                    case .object(let name):
                        if let meshIdentifier {
                            let mesh = createMesh(
                                vertices: vertices,
                                normals: normals,
                                uvs: uvs,
                                faces: indices
                            )
                            
                            repository.registerMesh(meshIdentifier, mesh: mesh)
                            
                            let submesh = GameObject()
                            submesh.name = meshIdentifier
                            submesh.addComponent(component: MeshRenderer(mesh: meshIdentifier, material: material))
                            object.addChild(submesh)
                        }
                        
                        vertexOffset += vertices.count
                        normalOffset += normals.count
                        uvOffset += uvs.count
                        
                        vertices = []
                        normals = []
                        uvs = []
                        indices = []
                        
                        let identifier = "\(url.absoluteString):\(name)"
                        meshIdentifier = identifier
                        
                        if repository.meshExists(name: identifier) {
                            meshIdentifier = nil
                        }
                    default:
                        continue
                }
            }
            
            if let meshIdentifier {
                let mesh = createMesh(vertices: vertices, normals: normals, uvs: uvs, faces: indices)
                repository.registerMesh(meshIdentifier, mesh: mesh)
                
                let submesh = GameObject()
                submesh.name = meshIdentifier
                submesh.addComponent(component: MeshRenderer(mesh: meshIdentifier, material: material))
                object.addChild(submesh)
            }
            
            return object
        } catch {
            return nil
        }
    }
    
    private static func parse(line: Substring) -> ObjectFileInstruction? {
        var components: [Substring] = line.split(separator: " ")
        
        guard let instruction = components.first else {
            return nil
        }
        
        components.removeFirst()
        
        switch instruction {
            case "o":
                guard let name = components.first else {
                    return nil
                }
                
                return .object(String(name))
            case "v":
                guard let x = components[safe: 0].flatMap(Float.init),
                      let y = components[safe: 1].flatMap(Float.init),
                      let z = components[safe: 2].flatMap(Float.init) else {
                          return nil
                      }
                
                return .vertex(.init(x, y, z))
            case "vn":
                guard let x = components[safe: 0].flatMap(Float.init),
                      let y = components[safe: 1].flatMap(Float.init),
                      let z = components[safe: 2].flatMap(Float.init) else {
                          return nil
                      }
                
                return .normal(.init(x, y, z))
            case "vt":
                guard let x = components[safe: 0].flatMap(Float.init),
                      let y = components[safe: 1].flatMap(Float.init) else {
                          return nil
                      }
                
                return .uv(.init(x, y))
            case "f":
                let points: [(Int, Int, Int)] = components.map { point in
                    let indices = point.split(separator: "/").compactMap { Int($0) }
                    return (indices[safe: 0] ?? 0, indices[safe: 1] ?? 0, indices[safe: 2] ?? 0)
                }
                
                return .face(points)
            case "l":
                return nil  // ignored for now.
            case "mtllib":
                return nil  // ignored for now.
            case "usemtl":
                return nil  // ignored for now.
            case "g":
                return nil  // ignored for now.
            case "s":
                return nil  // ignored for now.
            case "#":
                return nil
            default:
                print("OBJ Loader: Unknown instruction: \(instruction)")
                
                return nil
        }
    }
    
    private static func createMesh(
        vertices: [simd_float3],
        normals: [simd_float3],
        uvs: [simd_float2],
        faces: [(Int, Int, Int)]
    ) -> Mesh {
        var v = [simd_float3]()
        var n = [simd_float3]()
        var t = [simd_float3]()
        var u = [simd_float2]()
        var indices = [UInt32]()

        for (vertexIndex, uvIndex, normalIndex) in faces {
            v.append(vertices[vertexIndex - 1])
            n.append(normals[normalIndex - 1])
            let uv = uvs[uvIndex - 1]
            
            u.append(.init(uv.x, 1 - uv.y))
            indices.append(UInt32(indices.count))
        }
        
        for i in stride(from: 0, to: indices.count, by: 3) {
            let i0 = Int(indices[i])
            let i1 = Int(indices[i + 1])
            let i2 = Int(indices[i + 2])

            let uv0 = u[i0]
            let uv1 = u[i1]
            let uv2 = u[i2]

            let edge1 = i1 - i0
            let edge2 = i2 - i0
            let deltaUV1 = uv1 - uv0
            let deltaUV2 = uv2 - uv0

            let r = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV1.y * deltaUV2.x)
//            let tangent: simd_float3 = simd_normalize((edge1 * deltaUV2.y - edge2 * deltaUV1.y) * r)

//            t.append(contentsOf: [tangent, tangent, tangent])
        }
        
        return Mesh(
            vertices: v.withUnsafeBufferPointer { Data(buffer: $0) },
            indices: indices.withUnsafeBufferPointer { Data(buffer: $0) },
            normals: n.withUnsafeBufferPointer { Data(buffer: $0) },
            tangents: n.withUnsafeBufferPointer { Data(buffer: $0) },
            uv: u.withUnsafeBufferPointer { Data(buffer: $0) },
            boneIndices: nil
        )
    }
}
