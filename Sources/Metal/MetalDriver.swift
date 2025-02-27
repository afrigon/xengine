import MetalKit
import XEngineCore

public class MetalDriver: NSObject, MTKViewDelegate {
    public var input: Input = .init()
    private var renderer: MetalRenderer
    
    // State
    private var globals: Globals = .init()
    private var scene: GameScene
    
    public var debug: DebugOptions = .init()
    
    private var lastTime: Double? = nil
    
    public var resourceRepository: MetalResourceRepository {
        renderer.repository
    }

    public init?(scene: GameScene) {
        self.scene = scene
        
        guard let renderer = MetalRenderer() else {
            return nil
        }
        
        self.renderer = renderer
    }
    
    @MainActor
    func setup(_ view: XEngineView) {
        view.delegate = self
        view.input = input
        
        renderer.setup(with: view)
        resize(width: UInt32(view.frame.width), height: UInt32(view.frame.height))
    }
    
    private func resize(width: UInt32, height: UInt32) {
        globals.width = width
        globals.height = height
        
        for camera in scene.query(component: Camera.self) {
            camera.resize(width: width, height: height)
        }

        renderer.resize(width: width, height: height)
    }
    
    private func update() {
        let lastTime = lastTime ?? CACurrentMediaTime()
        let currentTime = CACurrentMediaTime()
        let delta = Float(currentTime - lastTime)
        
        self.lastTime = currentTime
        
        globals.deltaTime = delta
        
        scene.update(input: input, delta: delta)
        input.clearDelta()
        input.clearKeyboardUpdates()
        
        globals.projectionMatrix = scene.mainCamera?.projectionMatrix ?? .init(diagonal: .one)
        globals.viewMatrix = scene.mainCamera?.transform.matrix.inverse ?? .init(diagonal: .one)
    }
    
    public func draw(in view: MTKView) {
        update()
        
        #if DEBUG
        renderer.draw(scene: scene, globals: globals, in: view, debug: debug)
        #else
        renderer.draw(scene: scene, globals: globals, in: view)
        #endif
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        resize(width: UInt32(size.width), height: UInt32(size.height))
    }
}
