import Metal
import XEngineCore

class ScreenColorDepthRenderTarget: RenderTarget {
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
        self.createDescriptor(width: width, height: height)
    }
    
    func resize(width: Int, height: Int, device: MTLDevice) {
        self.createDescriptor(width: width, height: height)
    }
    
    func set(color texture: MTLTexture) {
        self.renderPassDescriptor?.colorAttachments[0].texture = texture
    }
    
    func set(depth texture: MTLTexture?) {
        self.renderPassDescriptor?.depthAttachment.texture = texture
    }

    private func createDescriptor(width: Int, height: Int) {
        
        // Render Pass Descriptor
        
        let descriptor = MTLRenderPassDescriptor()
        
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].clearColor = .init(
            red: Double(clearColor.red),
            green: Double(clearColor.green),
            blue: Double(clearColor.blue),
            alpha: Double(clearColor.alpha)
        )
        
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.storeAction = .dontCare
        descriptor.depthAttachment.clearDepth = 1.0
        
        self.renderPassDescriptor = descriptor
    }
}
