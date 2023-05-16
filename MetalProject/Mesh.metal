//
//  Mesh.metal
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 08/06/2023.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 pos [[position]];
};

struct primitiveData{
    float4 colour;
};

struct payloadData{
    float4 pos;
};


using triangle_mesh = metal::mesh<Vertex,
                                  primitiveData,
                                  193,
                                  192,
                                  metal::topology::triangle
>;


[[object]]
void objectShader(object_data payloadData* payload [[payload]],
                  constant simd_float4* inputData [[buffer(0)]],
                  uint threadID [[thread_position_in_threadgroup]],
                  mesh_grid_properties mgp
                  ){
    
    payload[threadID].pos = inputData[threadID];
    
    if(threadID == 0){
        mgp.set_threadgroups_per_grid(uint3(1,1,1));

    }
    
    
}

simd_float4 calculate_vertex(simd_float4 base, uint threadID){
    float angle = (float) threadID * 1.875;
    angle *= 3.14/180;
   
    switch (threadID){
        case 0:
            return base;
        default:
            return base + float4(cos(angle),sin(angle),0,0);
            
    }
    

        
            
}

static float3 hue2rgb(float hue) {
    hue = fract(hue); //only use fractional part of hue, making it loop
    float r = abs(hue * 6 - 3) - 1; //red
    float g = 2 - abs(hue * 6 - 2); //green
    float b = 2 - abs(hue * 6 - 4); //blue
    float3 rgb = float3(r,g,b); //combine components
    rgb = saturate(rgb); //clamp between 0 and 1
    return rgb;
}

[[mesh]]
void meshShader(triangle_mesh outputMesh,
                object_data const payloadData* payload [[payload]],
                uint threadID [[thread_position_in_threadgroup]],
                uint threadCount [[threads_per_threadgroup]]
                ){
    
    
    
    
    if(threadID == 0){
        outputMesh.set_primitive_count(threadCount - 1);
    }
    
//    if(threadID == 1){
//        primitiveData colour;
//        colour.colour = float4(1,0,0,1);
//        outputMesh.set_primitive(threadID, colour);
//    }
//    if(threadID == 0){
//        primitiveData colour;
//        colour.colour = float4(1,1,0,1);
//        outputMesh.set_primitive(threadID, colour);
//    }
    
    if(threadID < threadCount){
        Vertex v;
        v.pos = calculate_vertex(payload[0].pos, threadID) * simd_float4(0.25,0.5,0,1);
        outputMesh.set_vertex(threadID,v);
    }
    
    if(threadID < threadCount - 2){
        
        primitiveData colour;
        colour.colour = float4(hue2rgb(threadID * 1.71),1);
        outputMesh.set_primitive(threadID, colour);
        
        outputMesh.set_index(3 * threadID + 0, 0);
        outputMesh.set_index(3 * threadID + 1, threadID + 1);
        outputMesh.set_index(3 * threadID + 2, threadID + 2);
    }
    if(threadID == threadCount - 2){
        primitiveData colour;
        colour.colour = float4(hue2rgb(threadID * 1.71),1);
        outputMesh.set_primitive(threadID, colour);
        
        outputMesh.set_index(3 * threadID + 0, 0);
        outputMesh.set_index(3 * threadID + 1, threadCount - 1);
        outputMesh.set_index(3 * threadID + 2, 1);
    }
  
   
    
    
//    if(threadID == 0){
//        
//        Vertex v;
//        v.pos = payload[0].pos + float4(0.5,0,0,0);
//        outputMesh.set_vertex(threadID, v);
//    }
//    if(threadID == 1){
//        Vertex v;
//        v.pos = payload[0].pos + float4(0.5,0.5,0,0);
//        outputMesh.set_vertex(threadID, v);
//        
//    }
//    if(threadID == 2){
//        Vertex v;
//        v.pos = payload[0].pos + float4(0,0.5,0,0);
//        outputMesh.set_vertex(threadID, v);
//    }
    
   
        
    
    
    
}

struct FragmentIn{
    Vertex vertices;
    primitiveData info;
};

fragment float4 fragmentShader(FragmentIn in [[stage_in]]){
    return in.info.colour;
}



