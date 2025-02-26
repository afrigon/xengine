public struct KeyframeTimeline<T> {
    let keyframes: [Keyframe<T>]
    
    public init(keyframes: [Keyframe<T>]) {
        self.keyframes = keyframes
    }
    
    func value(at time: Float, interpolator: (T, T, Float) -> T) -> T? {
        guard !keyframes.isEmpty else {
            return nil
        }
        
        guard let first = keyframes.first, let last = keyframes.last else {
            return nil
        }
        
        if time <= first.time {
            return first.value(at: time)
        }
        
        if time >= last.time {
            return last.value(at: time)
        }
        
        var left: Keyframe<T> = first
        var right: Keyframe<T>? = nil
        
        var lo = 0
        var hi = keyframes.count - 1
        
        // Binary search to find the closest keyframes
        while lo <= hi {
            let mid = (lo + hi) / 2
            let midTime = keyframes[mid].time
            
            // early exit if matching keyframe
            if midTime == time {
                return keyframes[mid].value(at: time)
            }
            
            if midTime < time {
                left = keyframes[mid]
                lo = mid + 1
            } else {
                right = keyframes[mid]
                hi = mid - 1
            }
        }
        
        guard let right else {
            return left.value(at: time)
        }
        
        return interpolator(
            left.value(at: time),
            right.value(at: time),
            (time - left.time) / (right.time - left.time)
        )
    }
}
