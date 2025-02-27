import simd

extension Script {
    public static func fpsCamera(speed: Float = 4, sensitivity: Float = 0.002) -> Script {
        var rotation: simd_float2 = .zero
        
        return Script { object, input, delta in
            let maxPitch = Angle(degrees: 89).radians
            
            rotation.x += input.cursorDelta.x * sensitivity
            rotation.y += input.cursorDelta.y * sensitivity
            rotation.y = min(max(rotation.y, -maxPitch), maxPitch)
            
            let yaw = simd_quatf(angle: rotation.x, axis: .up)
            let pitch = simd_quatf(angle: rotation.y, axis: .right)
            
            object.transform.set(rotation: yaw * pitch)
            
            var direction = {
                var direction: simd_float3 = .init(0, 0, 0)
                
                if input.isHeld(key: .w) { direction.z += 1 }
                if input.isHeld(key: .a) { direction.x -= 1 }
                if input.isHeld(key: .d) { direction.x += 1 }
                if input.isHeld(key: .s) { direction.z -= 1 }
                if input.isHeld(key: .space) { direction.y += 1 }
                if input.isHeld(key: .shift) { direction.y -= 1 }
                
                return direction
            }()
            
            if direction != .zero {
                direction = simd_normalize(direction)
            }
            
            let rotation = object.transform.rotation
            
            var forward = rotation.act(.forward)
            var right = rotation.act(.right)
            
            forward.y = 0
            right.y = 0
            
            let movement = simd_normalize(right) * direction.x + simd_normalize(forward) * direction.z + .up * direction.y
            
            object.transform.set(position: object.transform.position + movement * speed * delta)
        }
    }
}
