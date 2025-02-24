public class DebugOptions {
    public var wireframe: Bool = false
    public var materialOverride: String? = nil
    
    public func toggleMaterial(_ material: String) {
        if materialOverride == material {
            materialOverride = nil
        } else {
            materialOverride = material
        }
    }
}
