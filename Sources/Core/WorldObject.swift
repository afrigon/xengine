import simd

public struct WorldObject<T> {
    public let transform: simd_float4x4
    public let object: T
    
    public init(transform: simd_float4x4, object: T) {
        self.transform = transform
        self.object = object
    }
}
