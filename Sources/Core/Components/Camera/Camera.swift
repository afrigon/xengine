import simd

public class Camera: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Camera"
    }
    
    public private(set) var projection: Projection

    public private(set) var viewProjectionMatrix: simd_float4x4
    public private(set) var projectionMatrix: simd_float4x4
    
    public var clearColor: Color
    public var postProcessing: PostProcessing
    
    // TODO: implement a system to choose render target

    public init(
        projection: Projection = .perspective(),
        clearColor: Color = .init(red: 0.1, green: 0.1, blue: 0.1),
        postProcessing: PostProcessing = .init(effects: [])
    ) {
        self.projection = projection
        self.projectionMatrix = projection.matrix
        self.clearColor = clearColor
        self.postProcessing = postProcessing
        self.viewProjectionMatrix = projectionMatrix * .init(diagonal: .one)
    }
    
    public func set(projection: Projection) {
        self.projection = projection
        projectionMatrix = projection.matrix
    }
    
    public func resize(width: UInt32, height: UInt32) {
        projection = projection.resized(width: width, height: height)
        projectionMatrix = projection.matrix
    }
    
    public func update(input: Input, delta: Float) {
        viewProjectionMatrix = projectionMatrix * transform.matrix.inverse
    }
    
    public func addPostProcessing(_ effect: PostProcessingEffect) {
        postProcessing.add(effect)
    }
}
