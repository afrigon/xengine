import simd
import Foundation

public class GameObject: GameUpdatable, Identifiable, Toggleable {
    public var id: UUID = .init()
    public var name: String? = nil
    public var enabled: Bool = true
    
    public var transform: Transform
    
    var components: [any GameComponent] = .init()
    
    private(set) public weak var parent: GameObject? = nil
    private(set) public var children: [GameObject] = []
    
    public init(name: String? = nil, transform: Transform = .init()) {
        self.name = name
        self.transform = transform
        self.transform.parent = self
    }
    
    public func addChild(_ child: GameObject) {
        child.parent = self
        self.children.append(child)
    }
    
    public func removeFromParent() {
        parent?.children.removeAll { $0.id == id }
        parent = nil
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
    
    public func query<T: GameComponent>(component type: T.Type) -> [T] {
        var results: [T] = getComponents(type)
            .filter { $0.enabled }

        for child in children where child.enabled {
            results.append(contentsOf: child.query(component: type))
        }
        
        return results
    }
    
    public func query(where predicate: (GameObject) -> Bool) -> [GameObject] {
        var results: [GameObject] = []
        
        if enabled && predicate(self) {
            results.append(self)
        }
        
        for child in children where child.enabled {
            results.append(contentsOf: child.query(where: predicate))
        }

        return results
    }
    
    public func update(input: Input, delta: Float) {
        for component in components where component.enabled {
            component.update(input: input, delta: delta)
        }
        
        for child in children where child.enabled {
            child.update(input: input, delta: delta)
        }
    }
}
