public struct BlinnPhongMaterialOptions {
    public let albedoColor: Color
    public let albedo: String?
    public let specularStrength: Float
    public let shininess: Float

    public var useAlbedoTexture: Bool {
        albedo != nil
    }

    public init(
        albedoColor: Color,
        albedo: String? = nil,
        specularStrength: Float = 1,
        shininess: Float = 128
    ) {
        self.albedoColor = albedoColor
        self.albedo = albedo
        self.specularStrength = specularStrength
        self.shininess = shininess
    }
}
