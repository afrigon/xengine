import simd
import XEngineCore

struct BlinnPhongData {
    let directionalLightCount: UInt32
    
    let useAlbedoTexture: Bool
    let albedoColor: simd_float3
    let specularStrength: Float
    let shininess: Float
    let eyePosition: simd_float3

    let alphaCutoff: Float
};
