public enum PostProcessingEffect {
    case identity
    case inverted
    case fxaa(FXAAOptions = .init())
    
    public var shader: String {
        switch self {
            case .identity:
                "identity"
            case .inverted:
                "inverted"
            case .fxaa:
                "fxaa"
        }
    }
    
    public var needsDepthTexture: Bool {
        switch self {
            default:
                false
        }
    }
        
    public var needsNormalTexture: Bool {
        false
    }
    
    public var needsTime: Bool {
        switch self {
            default:
                false
        }
    }
}

extension PostProcessingEffect {
    public static var fxaa: PostProcessingEffect {
        .fxaa()
    }
}
