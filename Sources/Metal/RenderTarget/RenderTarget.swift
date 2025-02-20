import Metal

protocol RenderTarget {
    var renderPassDescriptor: MTLRenderPassDescriptor? { get }

    func setup(width: Int, height: Int, device: MTLDevice)
    func resize(width: Int, height: Int, device: MTLDevice)
}
