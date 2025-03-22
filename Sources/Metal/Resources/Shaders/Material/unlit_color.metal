#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

fragment FragmentOutput fragment_unlit_color(
    RasterizerData input       [[stage_in]],
    constant Globals& globals  [[buffer(0)]],
    constant float4& color     [[buffer(1)]]
) {
    FragmentOutput output;
    
    output.color = color;
    output.normal = float4(normalize(input.normal) * 0.5 + 0.5, 1.0);
    
    return output;
}
