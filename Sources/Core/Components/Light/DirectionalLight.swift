import simd

public struct DirectionalLight {
    public var color: Color
    public var intensity: Float
    
    public init(color: Color, intensity: Float) {
        self.color = color
        self.intensity = intensity
    }
}
