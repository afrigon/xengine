#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

struct SSAOOptions {
    float3 kernel;
};

fragment float4 fragment_post_ssao(
    UnlitRasterizerData data       [[stage_in]],
    texture2d<float> input         [[texture(0)]],
    texture2d<float> normal        [[texture(2)]],
    constant Globals& globals      [[buffer(3)]],
    constant SSAOOptions& options  [[buffer(4)]],
    texture2d<float> noise         [[texture(5)]]
) {
    constexpr sampler s(
        address::repeat,
        mag_filter::linear,
        min_filter::linear
    );

    float4 n = noise.sample(s, data.uv);
    return float4(n.r, n.r, n.r, 1.0);
}
