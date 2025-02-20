import Metal
import XEngineCore

class ColorDepthRenderTarget: RenderTarget {
    private var colorTexture: MTLTexture? = nil
    private var depthTexture: MTLTexture? = nil
    
    private(set) var renderPassDescriptor: MTLRenderPassDescriptor?

    private let colorFormat: MTLPixelFormat
    private let depthFormat: MTLPixelFormat
    
    private var clearColor: Color = .init(red: 0.2, green: 0.2, blue: 0.2)
    
    init(colorFormat: MTLPixelFormat, depthFormat: MTLPixelFormat) {
        self.colorFormat = colorFormat
        self.depthFormat = depthFormat
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
        
        // Depth Texture
        
        let depthDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: colorFormat,
            width: width,
            height: height,
            mipmapped: false
        )
        depthDescriptor.usage = [.renderTarget]
        depthDescriptor.storageMode = .private

        self.depthTexture = device.makeTexture(descriptor: depthDescriptor)
        
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
        
        descriptor.depthAttachment.texture = depthTexture
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.storeAction = .dontCare
        descriptor.depthAttachment.clearDepth = 1.0
        
        self.renderPassDescriptor = descriptor
    }
}
