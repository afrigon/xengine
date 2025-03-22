import Metal
import XEngineCore

class ColorDepthNormalRenderTarget: RenderTarget {
    private(set) var colorTexture: MTLTexture? = nil
    private(set) var normalTexture: MTLTexture? = nil
    private(set) var depthTexture: MTLTexture? = nil
    
    private(set) var renderPassDescriptor: MTLRenderPassDescriptor?

    private let colorFormat: MTLPixelFormat
    private let normalFormat: MTLPixelFormat
    private let depthFormat: MTLPixelFormat
    
    private var clearColor: Color = .init(red: 0.2, green: 0.2, blue: 0.2)
    
    init(
        colorFormat: MTLPixelFormat,
        normalFormat: MTLPixelFormat,
        depthFormat: MTLPixelFormat
    ) {
        self.colorFormat = colorFormat
        self.normalFormat = normalFormat
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
            pixelFormat: depthFormat,
            width: width,
            height: height,
            mipmapped: false
        )
        depthDescriptor.usage = [.shaderRead, .renderTarget]
        depthDescriptor.storageMode = .private

        self.depthTexture = device.makeTexture(descriptor: depthDescriptor)
        
        // Normal Texture
        
        let normalDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: normalFormat,
            width: width,
            height: height,
            mipmapped: false
        )
        normalDescriptor.usage = [.shaderRead, .renderTarget]
        normalDescriptor.storageMode = .private

        self.normalTexture = device.makeTexture(descriptor: normalDescriptor)

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
        
        descriptor.colorAttachments[1].texture = normalTexture
        descriptor.colorAttachments[1].loadAction = .clear
        descriptor.colorAttachments[1].storeAction = .store
        descriptor.colorAttachments[1].clearColor = .init(red: 0.5, green: 0.5, blue: 1, alpha: 1)

        descriptor.depthAttachment.texture = depthTexture
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.storeAction = .store
        descriptor.depthAttachment.clearDepth = 1.0
        
        self.renderPassDescriptor = descriptor
    }
}
