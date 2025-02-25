public class Animator: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Animator"
    }
    
    var controller: AnimationController
    
    public init(controller: AnimationController) {
        self.controller = controller
    }
    
    public func update(input: Input, delta: Float) {
        controller.update(delta: delta)
        
        guard let parent else {
            return
        }
        
        let bones = parent.query(component: Bone.self)
        
        // update all bones
    }
}
