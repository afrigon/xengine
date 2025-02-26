import simd
import QuartzCore

/// - note: the `Animator` assumes it is attached to the game object with the root bone.
public class Animator: GameComponent {
    public weak var parent: GameObject?
    public var enabled: Bool = true
    
    public var name: String {
        "Animator"
    }
    
    var controller: AnimationController
    
    public init(controller: AnimationController) {
        self.controller = controller
    }
    
    public func update(input: Input, delta: Float) {
        controller.update(delta: delta)
        
        guard let parent else {
            return
        }
        
        setAnimationTransform(object: parent)
        
        // computes the final animation transform for each bone
        setBoneTransforms(object: parent)
    }
    
    private func setAnimationTransform(object: GameObject) {
        if let bone = object.getComponent(Bone.self) {
            bone.animationTransform = controller.transform(for: bone.boneName)
            
            for child in object.children {
                setAnimationTransform(object: child)
            }
        } else {
            for child in object.children {
                setAnimationTransform(object: child)
            }
        }
    }
    
    private func setBoneTransforms(object: GameObject, parent: simd_float4x4 = .init(diagonal: .one)) {
        if let bone = object.getComponent(Bone.self) {
            bone.poseTransform = parent * (bone.transform.matrix * bone.animationTransform)
            bone.finalTransform = bone.poseTransform * bone.inverseBindTransform
            
            for child in object.children {
                setBoneTransforms(object: child, parent: bone.finalTransform)
            }
        } else {
            // skip over all objects that have no bones
            for child in object.children {
                setBoneTransforms(object: child, parent: parent)
            }
        }
    }
}
