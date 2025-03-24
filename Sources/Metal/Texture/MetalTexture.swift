import Metal
import XEngineCore

class MetalTexture {
    let texture: MTLTexture
    let options: TextureOptions
    
    init(texture: MTLTexture, options: TextureOptions) {
        self.texture = texture
        self.options = options
    }
}
