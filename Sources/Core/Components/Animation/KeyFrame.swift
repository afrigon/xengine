import simd

struct KeyFrame {
    let time: Float
    
    let position: simd_float3
    let rotation: simd_quatf
    let scale: simd_float3
}
