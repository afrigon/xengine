#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

struct FogOptions {
    float near;
    float far;
    
    float3 color;
    float density;
};

fragment float4 fragment_post_fog(
    UnlitRasterizerData data      [[stage_in]],
    texture2d<float> input        [[texture(0)]],
    texture2d<float> depth        [[texture(1)]],
    constant FogOptions& options  [[buffer(4)]]
) {
    constexpr sampler s(
        address::repeat,
        mag_filter::linear,
        min_filter::linear
    );
    
    float3 color = input.sample(s, data.uv).rgb;
    float d = depth.sample(s, data.uv).r;
    
    // Convert depth to view-space
    float viewDepth = options.near * options.far / (options.far - d * (options.far - options.near));

    float factor = exp(-options.density * viewDepth);
    factor = clamp(factor, 0.0, 1.0);

    return float4(mix(options.color, color, factor), 1.0);
}
