import Testing
@testable import XEngineCore

struct KeyframeTimelineTests {
    func linear(a: Float, b: Float, t: Float) -> Float {
        a + (b - a) * t
    }
    
    @Test func no_keyframe() {
        let timeline = KeyframeTimeline<Float>(keyframes: [])
        
        let result = timeline.value(at: 0.5, interpolator: linear)
        
        #expect(result == nil)
    }
    
    @Test func one_keyframe() {
        let timeline = KeyframeTimeline<Float>(keyframes: [
            .init(time: 0, value: .value(10))
        ])
        
        let before = timeline.value(at: -2, interpolator: linear)
        let exact = timeline.value(at: 0, interpolator: linear)
        let after = timeline.value(at: 2, interpolator: linear)

        #expect(before == 10)
        #expect(exact == 10)
        #expect(after == 10)
    }
    
    @Test func two_keyframe() {
        let timeline = KeyframeTimeline<Float>(keyframes: [
            .init(time: 5, value: .value(50)),
            .init(time: 10, value: .value(100))
        ])
        
        let before = timeline.value(at: 4, interpolator: linear)
        let exact = timeline.value(at: 5, interpolator: linear)
        let middle = timeline.value(at: 7.5, interpolator: linear)
        let after = timeline.value(at: 12, interpolator: linear)

        #expect(before == 50)
        #expect(exact == 50)
        #expect(middle == 75)
        #expect(after == 100)
    }
}
