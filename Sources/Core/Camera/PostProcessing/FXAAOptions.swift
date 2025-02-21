public struct FXAAOptions {
    let threshold: Float
    let smoothness: Float
    let sensitivity: Float
    
    public init(
        threshold: Float = 1.0 / 128.0,
        smoothness: Float = 8.0,
        sensitivity: Float = 1.0 / 8.0
    ) {
        self.threshold = threshold
        self.smoothness = smoothness
        self.sensitivity = sensitivity
    }
}
