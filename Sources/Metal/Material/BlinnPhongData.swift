import simd
import XEngineCore

struct BlinnPhongData {
    let directionalLightCount: UInt32
    
    let useAlbedoTexture: Bool
    let albedoColor: simd_float3
};
