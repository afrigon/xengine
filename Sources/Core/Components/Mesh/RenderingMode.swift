public enum RenderingMode {
    case opaque
    case cutoff(alphaCutoff: Float = 0.5)
    case transparent
    
    var renderOrder: Int {
        switch self {
            case .opaque:
                0
            case .cutoff:
                1
            case .transparent:
                1
        }
    }
    
    public var alphaCutoff: Float {
        switch self {
            case .cutoff(let alphaCutoff):
                alphaCutoff
            default:
                0
        }
    }
}

extension RenderingMode: Equatable {
    public static func == (lhs: RenderingMode, rhs: RenderingMode) -> Bool {
        switch (lhs, rhs) {
            case (.opaque, .opaque):
                return true
            case (.cutoff, .cutoff):
                return true
            case (.transparent, .transparent):
                return true
            default:
                return false
        }
    }
}

extension RenderingMode: Comparable {
    public static func < (lhs: RenderingMode, rhs: RenderingMode) -> Bool {
        lhs.renderOrder < rhs.renderOrder
    }
}
    
