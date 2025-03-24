public struct TextureOptions: Hashable {
    public let wrapMode: TextureWrapMode
    public let filterMode: TextureFilterMode
    public let maxAnisotropy: Int
    
    public init(
        wrapMode: TextureWrapMode = .repeat,
        filterMode: TextureFilterMode = .linear,
        maxAnisotropy: Int = 1
    ) {
        self.wrapMode = wrapMode
        self.filterMode = filterMode
        self.maxAnisotropy = maxAnisotropy
    }
}
