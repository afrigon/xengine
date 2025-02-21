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
        
        let identity: simd_float4x4 = .init(rows: [
            .init(1, 0, 0, 0),
            .init(0, 1, 0, 0),
            .init(0, 0, 1, 0),
            .init(0, 0, 0, 1)
        ])
        
        for object in objects where object.enabled {
            results.append(contentsOf: object.query(parentTransform: identity, where: predicate))
        }
        
        return results
    }
}
