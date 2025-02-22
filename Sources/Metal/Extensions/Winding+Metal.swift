import Metal
import XEngineCore

extension Winding {
    var metal: MTLWinding {
        switch self {
            case .clockwise:
                .clockwise
            case .counterClockwise:
                .counterClockwise
        }
    }
}
