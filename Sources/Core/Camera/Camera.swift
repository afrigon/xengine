import simd

public class Camera {
    public private(set) var transform: Transform
    public private(set) var viewProjectionMatrix: simd_float4x4
    public private(set) var projectionMatrix: simd_float4x4
    
    public var postProcessing: PostProcessing
    public var wireframe: Bool = false

    public var clear: Color = .init(red: 0.1, green: 0.1, blue: 0.1)
    
    public init(
        transform: Transform = .init(),
        projection: Projection = .perspective(),
        postProcessing: PostProcessing = .init(effects: [])
    ) {
        self.transform = transform
        self.postProcessing = postProcessing
        projectionMatrix = projection.matrix
        viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
    }
    
    public func set(position: SIMD3<Float>) {
        self.transform.position = position
        viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
    }
    
    public func set(rotation: SIMD3<Float>) {
        self.transform.rotation = rotation
        viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
    }
    
    public func set(projection: Projection) {
        projectionMatrix = projection.matrix
        viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
    }
}
