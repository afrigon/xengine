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
}

extension PostProcessingEffect {
    public static var fxaa: PostProcessingEffect {
        .fxaa()
    }
}
