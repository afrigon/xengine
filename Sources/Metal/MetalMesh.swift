import simd
import Metal
import XEngineCore

public class MetalMesh {
    public let verticesBuffer: MTLBuffer
    public let indicesBuffer: MTLBuffer
    public let normalsBuffer: MTLBuffer
    public let tangentsBuffer: MTLBuffer
    public let uv0Buffer: MTLBuffer
    public let boneIndicesBuffer: MTLBuffer?

    public let indicesCount: Int
    
    public init?(device: MTLDevice?, mesh: Mesh) {
        let verticesSize = mesh.vertices.count
        let indicesSize = mesh.indices.count
        let normalsSize = mesh.normals.count
        let tangentsSize = mesh.tangents.count
        let uv0Size = mesh.uv.count
        
        // TODO: should I refactor the Mesh data to also have the data type encoded into it ?
        // this doesnt work with a list of UInt16 indices.
        indicesCount = indicesSize / 4
        
        guard verticesSize != 0 && indicesSize != 0 && normalsSize != 0 && tangentsSize != 0 && uv0Size != 0 else {
            return nil
        }
        
        // TODO: fix whatever happens when a buffer does not exists aka colors and uvs
        guard let verticesBuffer = device?.makeBuffer(length: verticesSize),
              let indicesBuffer = device?.makeBuffer(length: indicesSize),
              let normalsBuffer = device?.makeBuffer(length: normalsSize),
              let tangentsBuffer = device?.makeBuffer(length: tangentsSize),
              let uv0Buffer = device?.makeBuffer(length: uv0Size)
        else {
            return nil
        }
        
        mesh.vertices.withUnsafeBytes { dataPointer in
            guard let from = dataPointer.baseAddress else {
                return
            }
            
            verticesBuffer.contents().copyMemory(from: from, byteCount: verticesSize)
        }
        
        mesh.indices.withUnsafeBytes { dataPointer in
            guard let from = dataPointer.baseAddress else {
                return
            }
            
            indicesBuffer.contents().copyMemory(from: from, byteCount: indicesSize)
        }
        
        mesh.normals.withUnsafeBytes { dataPointer in
            guard let from = dataPointer.baseAddress else {
                return
            }
            
            normalsBuffer.contents().copyMemory(from: from, byteCount: normalsSize)
        }
        
        mesh.tangents.withUnsafeBytes { dataPointer in
            guard let from = dataPointer.baseAddress else {
                return
            }
            
            tangentsBuffer.contents().copyMemory(from: from, byteCount: tangentsSize)
        }
        
        mesh.uv.withUnsafeBytes { dataPointer in
            guard let from = dataPointer.baseAddress else {
                return
            }
            
            uv0Buffer.contents().copyMemory(from: from, byteCount: uv0Size)
        }
        
        self.verticesBuffer = verticesBuffer
        self.indicesBuffer = indicesBuffer
        self.normalsBuffer = normalsBuffer
        self.tangentsBuffer = tangentsBuffer
        self.uv0Buffer = uv0Buffer
        
        if let boneIndices = mesh.boneIndices, boneIndices.count != 0, let buffer = device?.makeBuffer(length: boneIndices.count) {
            boneIndices.withUnsafeBytes { dataPointer in
                guard let from = dataPointer.baseAddress else {
                    return
                }
                
                buffer.contents().copyMemory(from: from, byteCount: boneIndices.count)
            }
            
            self.boneIndicesBuffer = buffer
        } else {
            self.boneIndicesBuffer = nil
        }
    }
}
