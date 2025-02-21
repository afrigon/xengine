#ifndef COMMON_METAL
#define COMMON_METAL

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct ResterizerData {
    float4 position [[position]];
    half3 normal;
    half3 tangent;
    float2 uv0;
};

struct PostResterizerData {
    float4 position [[position]];
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
