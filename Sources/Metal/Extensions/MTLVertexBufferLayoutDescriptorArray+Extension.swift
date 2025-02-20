import Metal

extension MTLVertexBufferLayoutDescriptorArray {
    subscript(_ index: UInt32) -> MTLVertexBufferLayoutDescriptor {
        get { self[Int(index)] }
        set { self[Int(index)] = newValue }
    }
}
