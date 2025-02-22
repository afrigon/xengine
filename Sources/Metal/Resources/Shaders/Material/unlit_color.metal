#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

vertex UnlitRasterizerData vertex_unlit_color(
    uint id                         [[vertex_id]],
    constant Globals& globals       [[buffer(0)]],
    const device float3* positions  [[buffer(1)]],
    const device float3* normals    [[buffer(2)]],
    const device float3* tangents   [[buffer(3)]],
    const device float2* uv0        [[buffer(4)]]
) {
    UnlitRasterizerData output;

    output.position = globals.modelViewProjectionMatrix * float4(positions[id], 1.0);
    output.uv = uv0[id];

    return output;
}

fragment float4 fragment_unlit_color(
    UnlitRasterizerData input  [[stage_in]],
    constant Globals& globals  [[buffer(0)]],
    constant float4& color     [[buffer(1)]]
) {
    return color;
}
