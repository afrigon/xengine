import simd
import Metal

public class GameScene {
    public var camera: Camera = .init()
    public var objects: [GameObject] = []
    
    public init() { }
    
    public func update(input: Input, delta: Float) {
        for object in objects where object.enabled {
            object.update(input: input, delta: delta)
        }
    }
    
    public func query(where predicate: (GameObject) -> Bool) -> [WorldObject<GameObject>] {
        var results: [WorldObject<GameObject>] = []
        
        let identity = simd_float4x4(diagonal: .init(repeating: 1))
        
        for object in objects where object.enabled {
            results.append(contentsOf: object.query(parentTransform: identity, where: predicate))
        }
        
        return results
    }
    
    public func debug() {
        print("[X] Main Camera <Camera>")
        
        for layer in camera.postProcessing.layers {
            print(" └─ [X] Post Processing Layer <\(layer.effect.shader)>")
        }
        
        _debug(objects: objects)
    }
    
    private func _debug(objects: [GameObject], indent: Int = 0) {
        for object in objects {
            let name = object.name ?? "Unnamed Object"
            let components = object.components.map { $0.name }.joined(separator: ", ")
            
            print("\(String(repeating: " └─ ", count: indent))[\(object.enabled ? "X" : " ")] \(name) <\(components)>")
            
            _debug(objects: object.children, indent: indent + 1)
        }
    }
}
