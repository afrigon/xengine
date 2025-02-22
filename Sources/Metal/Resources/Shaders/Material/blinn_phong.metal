#include <metal_stdlib>

#include "../common.metal"
#include "../light.metal"

using namespace metal;

struct BlinnPhongData {
    uint directional_light_count;
    bool use_albedo_texture;
    float3 albedo_color;
};

vertex ResterizerData vertex_blinn_phong(
    uint id                         [[vertex_id]],
    constant Globals& globals       [[buffer(0)]],
    const device float3* positions  [[buffer(1)]],
    const device float3* normals    [[buffer(2)]],
    const device float3* tangents   [[buffer(3)]],
    const device float2* uv0        [[buffer(4)]]
) {
    ResterizerData output;

    output.position = globals.modelViewProjectionMatrix * float4(positions[id], 1.0);
    output.normal = normalize(globals.normalMatrix * normals[id]);
    output.tangent = normalize(globals.normalMatrix * tangents[id]);
    output.uv0 = uv0[id];
    
    return output;
}

fragment float4 fragment_blinn_phong(
    ResterizerData input                           [[stage_in]],
    constant Globals& globals                      [[buffer(0)]],
    constant BlinnPhongData& material_data         [[buffer(1)]],
    constant DirectionalLight* directional_lights  [[buffer(2)]],
    texture2d<half> albedo                         [[texture(3)]]
) {
    constexpr sampler linearSampler(
        address::repeat,
        mag_filter::linear,
        min_filter::linear
    );
    
    float3 diffuse = float3(0.0);
    
    for (uint i = 0; i < material_data.directional_light_count; i++) {
        DirectionalLight light = directional_lights[i];
        
        float diff = max(dot(input.normal, light.direction), 0.0);
        diffuse += diff * light.color * light.intensity;
    }
    
    float3 ambient = float3(0.1);
    float3 albedo_output = material_data.use_albedo_texture ? float3(albedo.sample(linearSampler, input.uv0).rgb) : material_data.albedo_color;
    return float4(albedo_output * (diffuse + ambient), 1.0);
}
