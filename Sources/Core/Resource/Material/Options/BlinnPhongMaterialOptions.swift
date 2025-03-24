public struct BlinnPhongMaterialOptions {
    public let albedoColor: Color
    public let albedo: String?
    public let specularStrength: Float
    public let shininess: Float
    public let samplingOptions: TextureSamplingOptions

    public var useAlbedoTexture: Bool {
        albedo != nil
    }

    public init(
        albedoColor: Color,
        albedo: String? = nil,
        specularStrength: Float = 1,
        shininess: Float = 128,
        samplingOptions: TextureSamplingOptions = .init()
    ) {
        self.albedoColor = albedoColor
        self.albedo = albedo
        self.specularStrength = specularStrength
        self.shininess = shininess
        self.samplingOptions = samplingOptions
    }
}
