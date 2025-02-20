import Metal

extension MTLVertexAttributeDescriptorArray {
    subscript(_ index: UInt32) -> MTLVertexAttributeDescriptor {
        get { self[Int(index)] }
        set { self[Int(index)] = newValue }
    }
}
