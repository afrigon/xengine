import Foundation

public class GameObject: GameUpdatable, Identifiable, Toggleable {
    public var name: String? = nil
    public var enabled: Bool = true

    public var transform: Transform
    private var components: [any GameComponent] = .init()
    
    public var children: [GameObject]
    
    public init(transform: Transform = .init(), children: [GameObject] = []) {
        self.transform = transform
        self.children = children
    }
    
    public func addComponent<T: GameComponent>(component: consuming T) {
        component.parent = self
        components.append(component)
    }
    
    public func getComponent<T: GameComponent>(_ type: T.Type) -> T? {
        components.first { $0 as? T != nil } as? T
    }
    
    public func getComponents<T: GameComponent>(_ type: T.Type) -> [T] {
        components.compactMap { $0 as? T }
    }
    
    public func update(input: Input, delta: Double) {
        for component in components where component.enabled {
            component.update(input: input, delta: delta)
        }
        
        for child in children where child.enabled {
            child.update(input: input, delta: delta)
        }
    }
}
