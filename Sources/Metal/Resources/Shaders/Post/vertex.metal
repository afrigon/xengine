#include <metal_stdlib>

#include "../common.metal"

using namespace metal;

vertex PostResterizerData vertex_post(uint id [[vertex_id]]) {
    float2 quad[6] = {
        float2(-1.0,  1.0),  // Top-left
        float2( 1.0, -1.0),  // Bottom-right
        float2(-1.0, -1.0),  // Bottom-left
        float2(-1.0,  1.0),  // Top-left
        float2( 1.0,  1.0),  // Top-right
        float2( 1.0, -1.0)   // Bottom-right
    };
    
    float2 uv[6] = {
        float2(0.0, 0.0),  // Top-left
        float2(1.0, 1.0),  // Bottom-right
        float2(0.0, 1.0),  // Bottom-left
        float2(0.0, 0.0),  // Top-left
        float2(1.0, 0.0),  // Top-right
        float2(1.0, 1.0)   // Bottom-right
    };

    PostResterizerData output;
    
    output.position = float4(quad[id], 0.0, 1.0);
    output.uv = uv[id];

    return output;
}
