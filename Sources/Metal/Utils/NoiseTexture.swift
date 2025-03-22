import Metal
import XEngineCore

class NoiseTexture {
    public let texture: MTLTexture
    
    init?<G: NoiseGenerator>(
        width: Int,
        height: Int,
        generator: G,
        device: MTLDevice
    ) {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .r32Float,
            width: width,
            height: height,
            mipmapped: false
        )
        
        descriptor.usage = [.shaderRead]
        descriptor.storageMode = .shared

        guard let texture = device.makeTexture(descriptor: descriptor) else {
            return nil
        }
        
        self.texture = texture
        
        var data = [Float](repeating: 0, count: width * height)
        
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                
                data[index] = generator.sample(at: (x, y))
            }
        }

        let region = MTLRegionMake2D(0, 0, width, height)
        let bytesPerRow = width * 4

        texture.replace(
            region: region,
            mipmapLevel: 0,
            withBytes: data,
            bytesPerRow: bytesPerRow
        )
    }
}
