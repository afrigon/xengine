import simd

public struct Keyframe<T> {
    let time: Float
    
    private let value: KeyframeValue<T>
    
    public init(time: Float, value: KeyframeValue<T>) {
        self.time = time
        self.value = value
    }
    
    func value(at time: Float) -> T {
        switch value {
            case .value(let value):
                value
            case .runtime(let f):
                f(time)
        }
    }
}
