#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

fragment float4 fragment_normals(
    RasterizerData input       [[stage_in]],
    constant Globals& globals  [[buffer(0)]]
) {
    return float4(normalize(input.normal) * 0.5 + 0.5, 1.0);
}
