public protocol NoiseGenerator {
    func sample<each T: BinaryInteger>(at location: (repeat each T)) -> Float
}
