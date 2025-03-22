#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

fragment FragmentOutput fragment_normals(
    RasterizerData input       [[stage_in]],
    constant Globals& globals  [[buffer(0)]]
) {
    FragmentOutput output;
    
    output.color = float4(normalize(input.normal) * 0.5 + 0.5, 1.0);
    output.normal = float4(normalize(input.normal) * 0.5 + 0.5, 1.0);
    
    return output;
}
