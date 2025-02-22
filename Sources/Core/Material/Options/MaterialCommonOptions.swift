public struct MaterialCommonOptions {
    public let renderingMode: RenderingMode
    public let cullingMode: CullingMode
    public let frontFacing: Winding
    public let depthBias: Bool

    public init(
        renderingMode: RenderingMode = .opaque,
        cullingMode: CullingMode = .back,
        frontFacing: Winding = .clockwise,
        depthBias: Bool = false
    ) {
        self.renderingMode = renderingMode
        self.cullingMode = cullingMode
        self.frontFacing = frontFacing
        self.depthBias = depthBias
    }
}
