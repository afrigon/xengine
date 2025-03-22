import simd

public struct FogOptions {
    let near: Float
    let far: Float
    
    let color: simd_float3
    let density: Float
    
    public init(
        near: Float = 0.05,
        far: Float = 1000,
        color: Color = .gray,
        density: Float = 0.01
    ) {
        self.near = near
        self.far = far
        self.color = color.rgb
        self.density = density
    }
    
    public init(
        projection: Projection,
        color: Color = .gray,
        density: Float = 0.01
    ) {
        switch projection {
            case .perspective(_, _, let near, let far):
                self.near = near
                self.far = far
        }
        
        self.color = color.rgb
        self.density = density
    }
}
