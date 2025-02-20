import simd

public struct Color {
    public var red: Float
    public var green: Float
    public var blue: Float
    public var alpha: Float
    
    public init(red: Float, green: Float, blue: Float, alpha: Float = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public var rgb: simd_float3 {
        simd_float3(red, green, blue)
    }
    
    public var rgba: simd_float4 {
        simd_float4(red, green, blue, alpha)
    }
}
