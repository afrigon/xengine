import Foundation

public class Mesh {
    public let vertices: Data
    public let indices: Data
    public let normals: Data
    public let tangents: Data
    public let uv: Data
    public let boneIndices: Data?

    public init(
        vertices: Data,
        indices: Data,
        normals: Data,
        tangents: Data,
        uv: Data,
        boneIndices: Data? = nil
    ) {
        self.vertices = vertices
        self.indices = indices
        self.normals = normals
        self.tangents = tangents
        self.uv = uv
        self.boneIndices = boneIndices
    }
}
