#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

fragment float4 fragment_unlit_color(
    RasterizerData input  [[stage_in]],
    constant Globals& globals  [[buffer(0)]],
    constant float4& color     [[buffer(1)]]
) {
    return color;
}
