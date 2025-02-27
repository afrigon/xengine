import simd
import Metal

public class GameScene {
    public var objects: [GameObject] = []
    
    public init() { }
    
    public func update(input: Input, delta: Float) {
        for object in objects where object.enabled {
            object.update(input: input, delta: delta)
        }
    }
    
    public var mainCamera: Camera? {
        query(component: Camera.self).first
    }
    
    public func query<T: GameComponent>(component type: T.Type) -> [T] {
        var results: [T] = []
        
        for object in objects where object.enabled {
            results.append(contentsOf: object.query(component: type))
        }
        
        return results
    }

    public func query(where predicate: (GameObject) -> Bool) -> [GameObject] {
        var results: [GameObject] = []
        
        for object in objects where object.enabled {
            results.append(contentsOf: object.query(where: predicate))
        }
        
        return results
    }
    
    public func debug() {
        _debug(objects: objects)
    }
    
    private func _debug(objects: [GameObject], indent: Int = 0) {
        for object in objects {
            let name = object.name ?? "Unnamed Object"
            let components = object.components.map { $0.name }.joined(separator: ", ")
            
            print("\(String(repeating: "    ", count: max(0, indent - 1)))\(indent != 0 ? " └─ " : "")[\(object.enabled ? "X" : " ")] \(name) <\(components)>")
            
            _debug(objects: object.children, indent: indent + 1)
        }
    }
}
