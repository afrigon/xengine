public struct BlinnPhongMaterialOptions {
    public let albedoColor: Color
    public let albedo: String?
    
    public var useAlbedoTexture: Bool {
        albedo != nil
    }

    public init(
        albedoColor: Color,
        albedo: String? = nil
    ) {
        self.albedoColor = albedoColor
        self.albedo = albedo
    }
}
