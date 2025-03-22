public struct WhiteNoise: NoiseGenerator {
    public init() {
        
    }
    
    public func sample<each T: BinaryInteger>(at location: (repeat each T)) -> Float {
        Float.random(in: 0...1)
    }
}
