#ifndef COMMON_METAL
#define COMMON_METAL

#include <simd/simd.h>

struct RasterizerData {
    float4 position  [[position]];
    float3 fragment_position;
    float3 normal;
    float3 tangent;
    float2 uv0;
};

struct FragmentOutput {
    float4 color   [[ color(0) ]];
    float4 normal  [[ color(1) ]];
};

struct UnlitRasterizerData {
    float4 position  [[position]];
    float2 uv;
};

struct Globals {
    uint width;
    uint height;
    
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 modelMatrix;
    matrix_float3x3 normalMatrix;
    matrix_float4x4 modelViewProjectionMatrix;
    
    float time;
    float deltaTime;
};
#endif
