public class PostProcessing: Toggleable {
    public var enabled: Bool = true
    
    public private(set) var layers: [PostProcessingLayer]
    
    public var effects: [PostProcessingEffect] {
        guard enabled else {
            return []
        }
        
        return layers
            .filter(\.enabled)
            .map(\.effect)
    }

    public init(effects: [PostProcessingEffect]) {
        self.layers = effects.map { PostProcessingLayer(effect: $0) }
    }
    
    public init(layers: [PostProcessingLayer]) {
        self.layers = layers
    }
}
