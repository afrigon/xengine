import Foundation

public enum Material {
    case unlitColor(UnlitColorMaterial)
    case blinnPhong(BlinnPhongMaterial)
    
    public func shader(type: RendererType = .basic) -> String {
        let name = switch self {
            case .unlitColor:
                "unlit_color"
            case .blinnPhong:
                "blinn_phong"
        }
        
        return "\(name)\(type.rawValue)"
    }
}
