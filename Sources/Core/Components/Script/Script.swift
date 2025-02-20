public class Script: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Script"
    }
    
    private var updateClosure: ((GameObject, Input, Double) -> Void)?
    
    public init(updateClosure: ((GameObject, Input, Double) -> Void)? = nil) {
        self.updateClosure = updateClosure
    }
    
    public func update(input: Input, delta: Double) {
        guard let parent else {
            return
        }
        
        updateClosure?(parent, input, delta)
    }
}
