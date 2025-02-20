import SwiftUI
import MetalKit

#if canImport(UIKit)
public struct MetalView: UIViewRepresentable {
    weak var driver: MetalDriver?
    var onSetup: (() -> Void)?
    
    public init(driver: MetalDriver, onSetup: (() -> Void)? = nil) {
        self.driver = driver
        self.onSetup = onSetup
    }
    
    public func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        
        driver?.setup(view)
        onSetup?()
        
        return view
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) { }
}
#endif

#if canImport(AppKit)
public struct MetalView: NSViewRepresentable {
    weak var driver: MetalRenderer?
    var onSetup: (() -> Void)?
    
    public init(driver: MetalDriver, onSetup: (() -> Void)? = nil) {
        self.driver = driver
        self.onSetup = onSetup
    }
    
    public func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        
        driver?.setup(view)
        onSetup?()
        
        return view
    }
    
    public func updateNSView(_ uiView: MTKView, context: Context) { }
}
#endif
