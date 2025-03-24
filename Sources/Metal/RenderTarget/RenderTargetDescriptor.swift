import Metal

struct RenderTargetDescriptor {
    let scale: Float
    let pixelFormat: MTLPixelFormat
    
    init(
        scale: Float = 1,
        pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    ) {
        self.scale = scale
        self.pixelFormat = pixelFormat
    }
}
