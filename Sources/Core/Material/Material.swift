import Foundation

public enum Material {
    case unlitColor(UnlitColorMaterial)
    
    public func shader(type: RendererType = .basic) -> String {
        let name = switch self {
            case .unlitColor:
                "unlit_color"
        }
        
        return "\(name)\(type.rawValue)"
    }
}
