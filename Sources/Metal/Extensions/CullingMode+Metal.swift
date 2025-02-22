import Metal
import XEngineCore

extension CullingMode {
    var metal: MTLCullMode {
        switch self {
            case .none:
                .none
            case .front:
                .front
            case .back:
                .back
        }
    }
}
