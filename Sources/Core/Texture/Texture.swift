import Foundation

public class Texture {
    public let data: Data
    public let width: Int
    public let height: Int
    public let bytesPerRow: Int
    public let textureFormat: TextureFormat
    
    public init(
        data: Data,
        width: Int,
        height: Int,
        bytesPerRow: Int,
        textureFormat: TextureFormat = .rgba8Unorm
    ) {
        self.data = data
        self.width = width
        self.height = height
        self.bytesPerRow = bytesPerRow
        self.textureFormat = textureFormat
    }
}
