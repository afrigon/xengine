public class Script: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Script"
    }
    
    private var updateClosure: ((GameObject, Input, Float) -> Void)?
    
    public init(updateClosure: ((GameObject, Input, Float) -> Void)? = nil) {
        self.updateClosure = updateClosure
    }
    
    public func update(input: Input, delta: Float) {
        guard let parent else {
            return
        }
        
        updateClosure?(parent, input, delta)
    }
}
