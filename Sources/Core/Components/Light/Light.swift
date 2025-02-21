public class Light: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Light"
    }
    
    public let options: LightOptions
    
    public init(
        options: LightOptions
    ) {
        self.options = options
    }
    
    public func update(input: Input, delta: Float) { }
}

extension Light {
    public static func directional(color: Color, intensity: Float) -> Light {
        .init(options: .directional(.init(color: color, intensity: intensity)))
    }
}
