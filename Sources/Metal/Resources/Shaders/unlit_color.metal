#include <metal_stdlib>
#include <simd/simd.h>

#include "common.metal"

using namespace metal;

vertex ResterizerData vertex_unlit_color(
    uint id                         [[vertex_id]],
    constant Globals& globals       [[buffer(0)]],
    const device float3* positions  [[buffer(1)]],
    const device half3* normals     [[buffer(2)]],
    const device half3* tangents    [[buffer(3)]],
    const device float2* uv0        [[buffer(4)]]
) {
    ResterizerData output;

    output.position = globals.modelViewProjectionMatrix * float4(positions[id], 1.0);

    output.normal = normalize(half3x3(globals.normalMatrix) * normals[id]);
    output.tangent = normalize(half3x3(globals.normalMatrix) * tangents[id]);
    output.uv0 = uv0[id];
    
    return output;
}

fragment half4 fragment_unlit_color(
    ResterizerData input                [[stage_in]],
    constant Globals& globals           [[buffer(0)]],
    constant half4& color               [[buffer(1)]]
) {
    return color;
}
