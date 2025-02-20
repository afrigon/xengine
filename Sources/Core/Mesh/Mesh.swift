import Foundation

public class Mesh {
    public let vertices: Data
    public let indices: Data
    public let normals: Data
    public let tangents: Data
    public let uv: Data
    
    public init(
        vertices: Data,
        indices: Data,
        normals: Data,
        tangents: Data,
        uv: Data
    ) {
        self.vertices = vertices
        self.indices = indices
        self.normals = normals
        self.tangents = tangents
        self.uv = uv
    }
}
