public enum MaterialOptions {
    case unlitColor(UnlitColorMaterialOptions)
    case blinnPhong(BlinnPhongMaterialOptions)
    
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
