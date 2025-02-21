public class PostProcessingLayer: Toggleable {
    public var enabled: Bool = true
    public var effect: PostProcessingEffect
    
    public init(effect: PostProcessingEffect) {
        self.effect = effect
    }
}
