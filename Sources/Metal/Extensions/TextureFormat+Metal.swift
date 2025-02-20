import XEngineCore
import Metal

extension TextureFormat {
    var metalPixelFormat: MTLPixelFormat {
        switch self {
            case .rgba8Unorm:
                return .rgba8Unorm
        }
    }
}
