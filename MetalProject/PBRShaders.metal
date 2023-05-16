//
//  PBRShaders.metal
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 19/05/2023.
//

#include <metal_stdlib>
using namespace metal;
#include "ShaderDefinition.h"
#include <simd/simd.h>


struct VertexIn{
    
    simd_float4 pos [[attribute(0)]];
    simd_float4 normal [[attribute(1)]];
    simd_float2 tex [[attribute(2)]];
    simd_float4 tangent [[attribute(3)]];
    simd_float4 bitangent [[attribute(4)]];
    
};
struct VertexOut{
    
    float4 pos [[position]];
    float pointSize [[point_size]];
    float4 colour;
    float4 world_normal;
    float4 eye_normal;
    float2 tex;
    float3 tex_3;
    float4 world_pos;
    float4 eye_pos;
    float3 tangent;
    float3 bitangent;
    float3 lightPos;
    
    
    
    
    
};

enum class textureIDs : int {
    cubeMap  = 0,
    flat = 1,
    Normal = 2,
    Displacement = 3,
    depth = 4,
};

enum class vertexBufferIDs : int {
    vertexBuffers = 0,
    instanceConstantsBuffer = 1,
    frameConstantsBuffer = 2,
    colour = 3,
    lightConstantBuffer = 4,
    lightbuffer = 5,
    lightCount = 6,
    lightPos = 7,
    
    
};
    

    struct FragmentOut {
        float4 Albedo [[color(0)]];
        float4 EyeNormal [[color(1)]];
        float4 EyePosition [[color(2)]];
        float depth [[depth(any)]];
    };
    
    
    vertex VertexOut gBuffer_vertex(VertexIn in [[stage_in]],
                                    const device InstanceConstants* instanceTransform [[buffer(vertexBufferIDs::instanceConstantsBuffer)]],
                                    constant FrameConstants& frameConstant [[buffer(vertexBufferIDs::frameConstantsBuffer)]],
                                    uint instance_index [[instance_id]]
                                    ){
        
        simd_float4x4 projectionMatrix = frameConstant.projectionMatrix;
        simd_float4x4 viewMatrix = frameConstant.viewMatrix;
        
        
        simd_float4x4 modelMatrix = instanceTransform[instance_index].modelMatrix;
        simd_float4x4 normalMatrix = instanceTransform[instance_index].normalMatrix;
        
        
        VertexOut out;
        
        out.eye_pos = viewMatrix * modelMatrix * in.pos;
        out.eye_normal = normalMatrix * in.normal;
        
        
        out.pos = projectionMatrix * out.eye_pos;
        out.tex = in.tex;
        
        return out;
        
        
    }
    
    struct FragmentShaderArguments {
        texture2d<float> Albedo;
        texture2d<float> Depth;
        texture2d<float> Position;
        
    };
    
    struct GBufferData{
        float4 drawable [[color(0),raster_order_group(1)]];
        float4 Albedo [[color(1),raster_order_group(0)]];
        float4 EyeNormal [[color(2),raster_order_group(0)]];
        float4 EyePosition [[color(3),raster_order_group(0)]];
        float Depth [[color(4),raster_order_group(0)]];
        
    };
    
    struct drawableOutPut{
        float4 drawable [[color(0),raster_order_group(1)]];
    };
    
    fragment GBufferData gBuffer_fragment(VertexOut in [[stage_in]],
                                          texture2d<float> Albedo [[texture(textureIDs::flat)]]
                                          ){
        
        constexpr sampler AlbedoSampler(coord::normalized,
                                        address::clamp_to_edge,
                                        filter::linear,
                                        compare_func::less);
        
        GBufferData out;
        out.Albedo = Albedo.sample(AlbedoSampler, in.tex);
        out.Depth = in.pos.z;
        out.EyeNormal = float4(normalize(in.eye_normal.rgb),1);
        out.EyePosition = in.eye_pos;
        
        return out;
        
    }
    
    
    
    
    
    vertex VertexOut deferred_vertex(VertexIn in [[stage_in]]){
        VertexOut out;
        out.pos = in.pos;
        out.tex = in.tex;
        return out;
        
    }
    
    fragment drawableOutPut deferred_fragment(VertexOut in [[stage_in]],
                                      constant simd_float4x4& screenToWorldTransform [[buffer(3)]],
                                      GBufferData gBuffer
                               ){
        
        constexpr sampler AlbedoSampler(coord::normalized,
                                        address::clamp_to_edge,
                                        filter::nearest,
                                        compare_func::less
                                        );
        
        drawableOutPut out;
        out.drawable = gBuffer.EyePosition;
        return out;

        
        
    }

