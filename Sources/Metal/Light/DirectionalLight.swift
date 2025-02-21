import simd

struct DirectionalLight {
    let direction: simd_float3
    let color: simd_float3
    let intensity: Float
}
