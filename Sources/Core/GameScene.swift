import Metal

public class GameScene {
    public var camera: Camera = .init()
    public var objects: [GameObject] = []
    
    public init() { }
    
    public func update(input: Input, delta: Double) {
        for object in objects where object.enabled {
            object.update(input: input, delta: delta)
        }
    }
    
    public func collectObjectsWithComponents<T: GameComponent>(_ type: T.Type) -> [GameObject] {
        collectObjectsWithComponents(from: objects, T.self)
    }
    
    private func collectObjectsWithComponents<T: GameComponent>(from objects: [GameObject], _ type: T.Type) -> [GameObject] {
        var results: [GameObject] = []
        
        for object in objects where object.enabled {
            if object.getComponent(type) != nil {
                results.append(object)
            }
            
            results.append(contentsOf: collectObjectsWithComponents(from: object.children, T.self))
        }
        
        return results
    }
}
