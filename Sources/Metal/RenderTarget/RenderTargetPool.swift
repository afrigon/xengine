import Metal

class RenderTargetPool {
    private weak var device: MTLDevice?
    
    private var width: Int = 0
    private var height: Int = 0

    weak var output: MTLTexture?
    private var targets: [RenderTargetIdentifier: RenderTarget] = [:]

    init(device: MTLDevice) {
        self.device = device
    }
    
    func get(_ identifier: RenderTargetIdentifier) -> MTLTexture? {
        switch identifier {
            case .output:
                output
            default:
                targets[identifier]?.texture
        }
    }
    
    func set(_ identifier: RenderTargetIdentifier, descriptor: RenderTargetDescriptor) {
        guard let target = allocate(identifier, descriptor: descriptor) else {
            return
        }
        
        targets[identifier] = target
    }
    
    private func allocate(_ identifier: RenderTargetIdentifier, descriptor: RenderTargetDescriptor) -> RenderTarget? {
        guard let device, identifier != .output else {
            return nil
        }
        
        let width = Int(Float(width) * descriptor.scale)
        let height = Int(Float(height) * descriptor.scale)
        
        guard width > 0, height > 0 else {
            return .init(descriptor: descriptor, texture: nil)
        }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: descriptor.pixelFormat,
            width: width,
            height: height,
            mipmapped: false
        )
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.storageMode = .private
        // TODO: find an elegant way to handle history buffer (previous frames). these are going to want shared storage mode

        return .init(
            descriptor: descriptor,
            texture: device.makeTexture(descriptor: textureDescriptor)
        )
    }
    
    func resize(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        guard let device else {
            return
        }
        
        for (identifier, target) in targets {
            set(identifier, descriptor: target.descriptor)
        }
    }
}
