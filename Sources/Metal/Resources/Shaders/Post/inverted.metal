#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

fragment float4 fragment_post_inverted(
    UnlitRasterizerData data  [[stage_in]],
    texture2d<float> input    [[texture(0)]]
) {
    constexpr sampler s(
        address::repeat,
        mag_filter::linear,
        min_filter::linear
    );
    
    return float4(1.0 - input.sample(s, data.uv).rgb, 1.0);
}
