import XEngineCore

enum RenderJob {
    case basic(mode: RenderingMode, shader: String, renderer: MeshRenderer)
    case skinned(mode: RenderingMode, shader: String, renderer: SkinnedMeshRenderer)
    
    var type: String {
        switch self {
            case .basic:
                "basic"
            case .skinned:
                "skinned"
        }
    }

    var shader: String {
        switch self {
            case .basic(_, let shader, _):
                shader
            case .skinned(_, let shader, _):
                shader
        }
    }
    
    var material: String {
        switch self {
            case .basic(_, _, let renderer):
                renderer.material
            case .skinned(_, _, let renderer):
                renderer.material
        }
    }
    
    var mesh: String {
        switch self {
            case .basic(_, _, let renderer):
                renderer.mesh
            case .skinned(_, _, let renderer):
                renderer.mesh
        }
    }
    
    var renderingMode: RenderingMode {
        switch self {
            case .basic(let mode, _, _):
                mode
            case .skinned(let mode, _, _):
                mode
        }
    }
}

extension RenderJob: Equatable {
    static func == (lhs: RenderJob, rhs: RenderJob) -> Bool {
        lhs.renderingMode == rhs.renderingMode &&
        lhs.shader == rhs.shader &&
        lhs.material == rhs.material &&
        lhs.mesh == rhs.mesh
    }
}

extension RenderJob: Comparable {
    static func < (lhs: RenderJob, rhs: RenderJob) -> Bool {
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
