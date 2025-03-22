import MetalKit
import XEngineCore

public class XEngineView: MTKView {
    weak var input: Input?
    
#if canImport(AppKit)
    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.window?.makeFirstResponder(self)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResignKey),
            name: NSWindow.didResignKeyNotification,
            object: self.window
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeKey),
            name: NSWindow.didBecomeKeyNotification,
            object: self.window
        )
    }
    
    @objc func windowDidBecomeKey(_ notification: Notification) {
        window?.acceptsMouseMovedEvents = true
    }

    @objc func windowDidResignKey(_ notification: Notification) {
        input?.clearKeyboard()
        setMouseLock(false)
        window?.acceptsMouseMovedEvents = false
    }
    
    public override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        
        setMouseLock(true)
        window?.acceptsMouseMovedEvents = true

        return true
    }

    public override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
        guard let key = Keycode(rawValue: event.keyCode) else {
            return
        }
        
        guard !event.isARepeat else {
            return
        }
        
        input?.pressed(.keyboard(key))
        
        if event.keyCode == 53 {
            setMouseLock(false)
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        
        guard let key = Keycode(rawValue: event.keyCode) else {
            return
        }
        
        input?.released(.keyboard(key))
    }
    
    public override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        
        input?.addCursorDelta(Float(event.deltaX), Float(event.deltaY))
    }
    
    public override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        
        input?.addScrollDelta(Float(event.deltaX), Float(event.deltaY))
    }
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        input?.pressed(.mouse(event.buttonNumber))

        setMouseLock(true)
    }
    
    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        
        input?.released(.mouse(event.buttonNumber))
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        
        input?.pressed(.mouse(event.buttonNumber))
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        
        input?.released(.mouse(event.buttonNumber))
    }
    
    public override func otherMouseDown(with event: NSEvent) {
        super.otherMouseDown(with: event)
        
        input?.pressed(.mouse(event.buttonNumber))
    }

    public override func otherMouseUp(with event: NSEvent) {
        super.otherMouseUp(with: event)
        
        input?.released(.mouse(event.buttonNumber))
    }
    
    public override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
        
        if event.modifierFlags.contains(.capsLock) {
            input?.pressed(.keyboard(.capsLock))
        } else {
            input?.released(.keyboard(.capsLock))
        }
        
        if event.modifierFlags.contains(.shift) {
            input?.pressed(.keyboard(.shift))
        } else {
            input?.released(.keyboard(.shift))
        }
        
        if event.modifierFlags.contains(.control) {
            input?.pressed(.keyboard(.control))
        } else {
            input?.released(.keyboard(.control))
        }
        
        if event.modifierFlags.contains(.option) {
            input?.pressed(.keyboard(.option))
        } else {
            input?.released(.keyboard(.option))
        }
        
        if event.modifierFlags.contains(.command) {
            input?.pressed(.keyboard(.command))
        } else {
            input?.released(.keyboard(.command))
        }
        
        if event.modifierFlags.contains(.function) {
            input?.pressed(.keyboard(.function))
        } else {
            input?.released(.keyboard(.function))
        }
    }
    
    private func setMouseLock(_ locked: Bool) {
        if locked {
            CGAssociateMouseAndMouseCursorPosition(0)
            NSCursor.hide()
        } else {
            CGAssociateMouseAndMouseCursorPosition(1)
            NSCursor.unhide()
        }
    }
#endif
}
