import simd

public class Camera {
    public private(set) var transform: Transform
    public private(set) var viewProjectionMatrix: simd_float4x4
    public private(set) var projectionMatrix: simd_float4x4
    
    public var projection: Projection {
        didSet {
            projectionMatrix = projection.matrix
            viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
        }
    }
    
    public var postProcessing: PostProcessing

    public var clear: Color = .init(red: 0.1, green: 0.1, blue: 0.1)
    
    public init(
        transform: Transform = .init(),
        projection: Projection = .perspective(),
        postProcessing: PostProcessing = .init(effects: [])
    ) {
        self.transform = transform
        self.postProcessing = postProcessing
        self.projection = projection
        
        projectionMatrix = projection.matrix
        viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
    }
    
    public func set(position: simd_float3) {
        self.transform.position = position
        
        viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
    }
    
    public func set(rotation: simd_float3) {
        self.transform.rotation = rotation
        
        viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
    }
    
    public func look(at target: Transform, up: simd_float3 = .init(1, 1, 0)) {
        transform.look(at: target)
        viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
    }
}
