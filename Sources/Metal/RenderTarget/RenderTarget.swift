import Metal

class RenderTarget {
    let descriptor: RenderTargetDescriptor
    var texture: MTLTexture?
    
    init(descriptor: RenderTargetDescriptor, texture: MTLTexture?) {
        self.descriptor = descriptor
        self.texture = texture
    }
}
