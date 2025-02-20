struct RenderableIdentifier: Comparable, Equatable {
    let shader: String
    let material: String
    let mesh: String
    
    static func < (lhs: RenderableIdentifier, rhs: RenderableIdentifier) -> Bool {
        if lhs.shader == rhs.shader {
            if lhs.material == rhs.material {
                return lhs.mesh < rhs.mesh
            }
            
            return lhs.material < rhs.material
        }
        
        return lhs.shader < rhs.shader
    }
}
