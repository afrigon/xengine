#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

fragment half4 fragment_post_inverted(
    UnlitRasterizerData data  [[stage_in]],
    texture2d<half> input     [[texture(0)]]
) {
    constexpr sampler linearSampler(
        address::repeat,
        mag_filter::linear,
        min_filter::linear
    );
    
    return half4(1.0 - input.sample(linearSampler, data.uv).rgb, 1.0);
}
