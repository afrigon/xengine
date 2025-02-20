import MetalKit
import XEngineCore

public class MetalDriver: NSObject, MTKViewDelegate {
    private var input: Input = .init()
    private var renderer: MetalRenderer
    
    // State
    private var globals: Globals = .init()
    private var scene: GameScene

    public init?(scene: GameScene) {
        self.scene = scene
        
        guard let renderer = MetalRenderer() else {
            return nil
        }
        
        self.renderer = renderer
    }
    
    func setup(_ view: MTKView) {
        view.delegate = self
        
        renderer.setup(with: view)
        resize(width: UInt32(view.frame.width), height: UInt32(view.frame.height))
    }
    
    private func resize(width: UInt32, height: UInt32) {
        globals.width = width
        globals.height = height
        scene.camera.set(projection: .perspective(aspect: Float(width) / Float(height)))

        renderer.resize(width: width, height: height)
    }
    
    private func update() {
        let lastTime = globals.time ?? CACurrentMediaTime()
        let currentTime = CACurrentMediaTime()
        let delta = currentTime - lastTime
        globals.time = currentTime
        globals.deltaTime = delta
        
        scene.update(input: input, delta: delta)
        input.clearCursorDelta()
        
        globals.projectionMatrix = scene.camera.projectionMatrix
        globals.viewMatrix = scene.camera.transform.matrix.inverse
    }
    
    public func draw(in view: MTKView) {
        update()
        renderer.draw(scene: scene, globals: globals, in: view)
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        resize(width: UInt32(size.width), height: UInt32(size.height))
    }
}
