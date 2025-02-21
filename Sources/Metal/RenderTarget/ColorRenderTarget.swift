import Metal
import XEngineCore

class ColorRenderTarget: RenderTarget {
    private(set) var colorTexture: MTLTexture? = nil
    
    private(set) var renderPassDescriptor: MTLRenderPassDescriptor?

    private let colorFormat: MTLPixelFormat
    
    private var clearColor: Color = .init(red: 0.2, green: 0.2, blue: 0.2)
    
    init(colorFormat: MTLPixelFormat) {
        self.colorFormat = colorFormat
    }
    
    func setClearColor(_ color: Color) {
        self.clearColor = color
        
        renderPassDescriptor?.colorAttachments[0].clearColor = .init(
            red: Double(color.red),
            green: Double(color.green),
            blue: Double(color.blue),
            alpha: Double(color.alpha)
        )
    }

    func setup(width: Int, height: Int, device: MTLDevice) {
        self.createDescriptor(width: width, height: height, device: device)
    }
    
    func resize(width: Int, height: Int, device: MTLDevice) {
        self.createDescriptor(width: width, height: height, device: device)
    }
    
    private func createDescriptor(width: Int, height: Int, device: MTLDevice) {
        
        // Color Texture
        
        let colorTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: colorFormat,
            width: width,
            height: height,
            mipmapped: false
        )
        colorTextureDescriptor.usage = [.shaderRead, .renderTarget]
        colorTextureDescriptor.storageMode = .private

        self.colorTexture = device.makeTexture(descriptor: colorTextureDescriptor)
        
        // Render Pass Descriptor
        
        let descriptor = MTLRenderPassDescriptor()
        
        descriptor.colorAttachments[0].texture = colorTexture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].clearColor = .init(
            red: Double(clearColor.red),
            green: Double(clearColor.green),
            blue: Double(clearColor.blue),
            alpha: Double(clearColor.alpha)
        )
        
        self.renderPassDescriptor = descriptor
    }
}
