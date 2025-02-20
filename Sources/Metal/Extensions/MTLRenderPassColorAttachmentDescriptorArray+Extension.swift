import Metal

extension MTLRenderPassColorAttachmentDescriptorArray {
    subscript(_ index: UInt32) -> MTLRenderPassColorAttachmentDescriptor {
        get { self[Int(index)] }
        set { self[Int(index)] = newValue }
    }
}
