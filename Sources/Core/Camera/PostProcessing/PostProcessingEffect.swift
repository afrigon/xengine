// identity
// inverted
// fxaa
// fog
//
// input texture -> ssao -> blur -> blend
//               |------------------^
// ssao
//
//   AO -> texture
//   Blur -> texture
//   Merge -> texture

public enum PostProcessingEffect {
    case identity
    case inverted
    case fxaa(FXAAOptions = .init())
    case fog(FogOptions)
    case ssao

    public var shader: String {
        switch self {
            case .identity:
                "identity"
            case .inverted:
                "inverted"
            case .fxaa:
                "fxaa"
            case .fog:
                "fog"
            case .ssao:
                "ssao"
        }
    }
    
    public var needsDepthTexture: Bool {
        switch self {
            case .fog:
                true
            default:
                false
        }
    }
        
    public var needsNormalTexture: Bool {
        switch self {
            case .ssao:
                true
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
