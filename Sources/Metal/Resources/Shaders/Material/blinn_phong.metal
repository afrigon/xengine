#include <metal_stdlib>

#include "../common.metal"
#include "../light.metal"

using namespace metal;

struct BlinnPhongData {
    uint directional_light_count;
    bool use_albedo_texture;
    float3 albedo_color;
    float alpha_cutoff;
};

fragment float4 fragment_blinn_phong(
    RasterizerData input                           [[stage_in]],
    constant Globals& globals                      [[buffer(0)]],
    constant BlinnPhongData& material_data         [[buffer(1)]],
    constant DirectionalLight* directional_lights  [[buffer(2)]],
    texture2d<half> albedo                         [[texture(3)]]
) {
//    constexpr sampler linearSampler(
//        address::repeat,
//        mag_filter::linear,
//        min_filter::linear
//    );
    
        constexpr sampler linearSampler(
            address::repeat,
            mag_filter::nearest,
            min_filter::nearest
        );

    float3 diffuse = float3(0.0);
    
    for (uint i = 0; i < material_data.directional_light_count; i++) {
        DirectionalLight light = directional_lights[i];
        
        float diff = max(dot(input.normal, light.direction), 0.0);
        diffuse += diff * light.color * light.intensity;
    }
    
    float3 ambient = float3(0.1);
    float4 albedo_output = material_data.use_albedo_texture ? float4(albedo.sample(linearSampler, input.uv0)) : float4(material_data.albedo_color, 1.0);
    
    if (albedo_output.a < material_data.alpha_cutoff) {
        discard_fragment();
    }
    
    return albedo_output * float4(diffuse + ambient, 1.0);
}
