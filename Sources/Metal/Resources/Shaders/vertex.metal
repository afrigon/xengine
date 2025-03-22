#include <metal_stdlib>

#include "common.metal"

using namespace metal;

vertex UnlitRasterizerData vertex_quad(uint id [[vertex_id]]) {
    float2 quad[6] = {
        float2(-1.0,  1.0),  // Top-left
        float2( 1.0, -1.0),  // Bottom-right
        float2(-1.0, -1.0),  // Bottom-left
        float2(-1.0,  1.0),  // Top-left
        float2( 1.0,  1.0),  // Top-right
        float2( 1.0, -1.0)   // Bottom-right
    };
    
    float2 uv[6] = {
        float2(0.0, 0.0),  // Top-left
        float2(1.0, 1.0),  // Bottom-right
        float2(0.0, 1.0),  // Bottom-left
        float2(0.0, 0.0),  // Top-left
        float2(1.0, 0.0),  // Top-right
        float2(1.0, 1.0)   // Bottom-right
    };

    UnlitRasterizerData output;
    
    output.position = float4(quad[id], 0.0, 1.0);
    output.uv = uv[id];

    return output;
}

vertex RasterizerData vertex_basic(
    uint id                             [[vertex_id]],
    constant Globals& globals           [[buffer(0)]],
    const device float3* positions      [[buffer(1)]],
    const device float3* normals        [[buffer(2)]],
    const device float3* tangents       [[buffer(3)]],
    const device float2* uv0            [[buffer(4)]]
) {
    RasterizerData output;

    output.position = globals.modelViewProjectionMatrix * float4(positions[id], 1.0);
    output.fragment_position = float3(globals.modelMatrix * float4(positions[id], 1.0));
    output.normal = normalize(globals.normalMatrix * normals[id]);
    output.tangent = normalize(globals.normalMatrix * tangents[id]);
    output.uv0 = uv0[id];
    
    return output;
}

vertex RasterizerData vertex_skinned(
    uint id                             [[vertex_id]],
    constant Globals& globals           [[buffer(0)]],
    const device float3* positions      [[buffer(1)]],
    const device float3* normals        [[buffer(2)]],
    const device float3* tangents       [[buffer(3)]],
    const device float2* uv0            [[buffer(4)]],
    const device uint* bone_indices     [[buffer(5)]],
    constant matrix_float4x4* bones     [[buffer(6)]]
) {
    RasterizerData output;

    matrix_float4x4 bone = bones[bone_indices[id]];
    output.position = globals.modelViewProjectionMatrix * (bone * float4(positions[id], 1.0));
    output.fragment_position = float3(globals.modelMatrix * (bone * float4(positions[id], 1.0)));

    float3x3 boneRotation = float3x3(bone.columns[0].xyz,
                                     bone.columns[1].xyz,
                                     bone.columns[2].xyz);
    
    output.normal = normalize(globals.normalMatrix * (boneRotation * normals[id]));
    output.tangent = normalize(globals.normalMatrix * (boneRotation * tangents[id]));
    
    output.uv0 = uv0[id];
    
    return output;
}
