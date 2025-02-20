import Metal

extension MTLRenderCommandEncoder {
    func setVertexBuffer(_ buffer: MTLBuffer?, offset: Int = 0, index: UInt32) {
        setVertexBuffer(buffer, offset: offset, index: Int(index))
    }
    
    func setFragmentBuffer(_ buffer: MTLBuffer?, offset: Int = 0, index: UInt32) {
        setFragmentBuffer(buffer, offset: offset, index: Int(index))
    }
    
    func setFragmentTexture(_ texture: MTLTexture?, index: UInt32) {
        setFragmentTexture(texture, index: Int(index))
    }
}
