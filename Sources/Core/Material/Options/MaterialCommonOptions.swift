public struct MaterialCommonOptions {
    public let cullingMode: CullingMode
    public let frontFacing: Winding
    public let depthBias: Bool

    public init(cullingMode: CullingMode = .none, frontFacing: Winding = .clockwise, depthBias: Bool = false) {
        self.cullingMode = cullingMode
        self.frontFacing = frontFacing
        self.depthBias = depthBias
    }
}
