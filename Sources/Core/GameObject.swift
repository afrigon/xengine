import simd

public class GameObject: GameUpdatable, Identifiable, Toggleable {
    public var name: String? = nil
    public var enabled: Bool = true

    public var transform: Transform
    var components: [any GameComponent] = .init()
    
    public var children: [GameObject] = []
    
    public init(name: String? = nil, transform: Transform = .init()) {
        self.name = name
        self.transform = transform
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
    
    func query(parentTransform: simd_float4x4, where predicate: (GameObject) -> Bool) -> [WorldObject<GameObject>] {
        let transform = parentTransform * transform.matrix
        
        var results: [WorldObject<GameObject>] = []
        
        if predicate(self) {
            results.append(.init(
                transform: transform,
                object: self
            ))
        }
        
        for child in children where child.enabled {
            results.append(contentsOf: child.query(parentTransform: transform, where: predicate))
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
