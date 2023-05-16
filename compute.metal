//
//  compute.metal
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 13/06/2023.
//

#include <metal_stdlib>
using namespace metal;


[[visible]]
float4 even(){
    return float4(1,0,0,1);
}

[[visible]]
float4 odd(){
    return float4(0,1,0,1);
}


kernel void test_compute(texture2d<float, access::write> input [[texture(0)]],
                         uint2 id [[thread_position_in_grid]],
                         visible_function_table<float4()> functions [[buffer(1)]]
                         ){
    uint functionID = id.x % 2;
    input.write(functions[functionID](),id);
}





