#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

struct FXAAOptions {
    float threshold;
    float smoothness;
    float sensitivity;
};

fragment half4 fragment_post_fxaa(
    PostResterizerData data         [[stage_in]],
    texture2d<half> input           [[texture(0)]],
    constant FXAAOptions& options   [[buffer(1)]]
) {
    constexpr sampler linearSampler(
        address::repeat,
        mag_filter::linear,
        min_filter::linear
    );
    
    float2 texel_size = 1.0 / float2(input.get_width(), input.get_height());

    half3 rgb_north_west = input.sample(linearSampler, data.uv + float2(-1.0, -1.0) * texel_size).rgb;
    half3 rgb_north_east = input.sample(linearSampler, data.uv + float2(1.0, -1.0) * texel_size).rgb;
    half3 rgb_south_west = input.sample(linearSampler, data.uv + float2(-1.0, 1.0) * texel_size).rgb;
    half3 rgb_south_east = input.sample(linearSampler, data.uv + float2(1.0, 1.0) * texel_size).rgb;
    half3 rgb_current = input.sample(linearSampler, data.uv).rgb;
    
    half3 luma = half3(0.299, 0.587, 0.114);
    float luma_north_west = dot(rgb_north_west, luma);
    float luma_north_east = dot(rgb_north_east, luma);
    float luma_south_west = dot(rgb_south_west, luma);
    float luma_south_east = dot(rgb_south_east, luma);
    float luma_current = dot(rgb_current, luma);
    
    float luma_min = min(luma_current, min(min(luma_north_west, luma_north_east), min(luma_south_west, luma_south_east)));
    float luma_max = max(luma_current, max(max(luma_north_west, luma_north_east), max(luma_south_west, luma_south_east)));
    
    // edge detection, gives the blur direction
    float2 direction = float2(
        -((luma_north_west + luma_north_east) - (luma_south_west + luma_south_east)),
        (luma_north_west + luma_south_west) - (luma_north_east + luma_south_east)
    );
    
    // hack to avoid division by zero errors
    float direction_reduction = max(
        options.threshold,
        (luma_north_west + luma_north_east + luma_south_west + luma_south_east) * (0.25 * options.sensitivity)  // biased luma average
    );
    
    float reciprocal_scaler = 1.0 / (min(abs(direction.x), abs(direction.y)) + direction_reduction);
    
    // this is the scaled direction vector used to apply the blur
    direction = clamp(direction * reciprocal_scaler, -options.smoothness, options.smoothness) * texel_size;
    
    half3 rgb_near = (1.0/2.0) * (
        input.sample(linearSampler, data.uv + direction * (1.0/3.0 - 0.5)).rgb +
        input.sample(linearSampler, data.uv + direction * (2.0/3.0 - 0.5)).rgb
    );
    
    half3 rgb_far = rgb_near * (1.0/2.0) + (1.0/4.0) * (
        input.sample(linearSampler, data.uv + direction * (0.0/3.0 - 0.5)).rgb +
        input.sample(linearSampler, data.uv + direction * (3.0/3.0 - 0.5)).rgb
    );
    
    float luma_far = dot(rgb_far, luma);
    
    return half4((luma_far < luma_min || luma_far > luma_max) ? rgb_near : rgb_far, 1.0);
}
