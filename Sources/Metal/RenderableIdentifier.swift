import XEngineCore

struct RenderableIdentifier: Comparable, Equatable {
    let renderingMode: RenderingMode
    let shader: String
    let material: String
    let mesh: String
    
    static func < (lhs: RenderableIdentifier, rhs: RenderableIdentifier) -> Bool {
        if lhs.renderingMode == rhs.renderingMode {
            if lhs.shader == rhs.shader {
                if lhs.material == rhs.material {
                    return lhs.mesh < rhs.mesh
                }
                
                return lhs.material < rhs.material
            }
            
            return lhs.shader < rhs.shader
        }

        return lhs.renderingMode < rhs.renderingMode
    }
}
