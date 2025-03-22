#include <metal_stdlib>

#include "../common.metal"
#include "../light.metal"

using namespace metal;

struct BlinnPhongData {
    uint directional_light_count;
    bool use_albedo_texture;
    float3 albedo_color;
    float specular_strength;
    float shininess;
    float3 eye_position;
    float alpha_cutoff;
};

fragment FragmentOutput fragment_blinn_phong(
    RasterizerData input                           [[stage_in]],
    constant Globals& globals                      [[buffer(0)]],
    constant BlinnPhongData& material_data         [[buffer(1)]],
    constant DirectionalLight* directional_lights  [[buffer(2)]],
    texture2d<half> albedo                         [[texture(3)]]
) {
//    constexpr sampler linearSampler(
//        address::clamp_to_edge,
//        mag_filter::linear,
//        min_filter::linear
//    );
    
    constexpr sampler linearSampler(
        address::repeat,
        mag_filter::nearest,
        min_filter::nearest
    );

    float3 diffuse = float3(0.0);
    float3 specular = float3(0.0);
    
    float3 view_direction = normalize(material_data.eye_position - input.fragment_position);
    float3 normal = normalize(input.normal);
    
    for (uint i = 0; i < material_data.directional_light_count; i++) {
        DirectionalLight light = directional_lights[i];
        
        float diff = max(dot(normal, light.direction), 0.0);
        diffuse += diff * light.color * light.intensity;
        
        float3 reflection_direction = reflect(-light.direction, normal);
        float spec = pow(max(dot(view_direction, reflection_direction), 0.0), material_data.shininess);
        specular += spec * material_data.specular_strength * light.color * light.intensity;
    }
    
    float3 ambient = float3(0.1);
    float4 albedo_output = material_data.use_albedo_texture ? float4(albedo.sample(linearSampler, input.uv0)) : float4(material_data.albedo_color, 1.0);
    
    if (albedo_output.a < material_data.alpha_cutoff) {
        discard_fragment();
    }
    
    FragmentOutput output;
    
    output.color = albedo_output * float4(diffuse + specular + ambient, 1.0);
    output.normal = float4(normal * 0.5 + 0.5, 1.0);
    
    return output;
}
