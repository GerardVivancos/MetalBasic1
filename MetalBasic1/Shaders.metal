//
//  Shaders.metal
//  MetalBasic1
//
//  Created by garbage on 02/08/2020.
//  Copyright © 2020 tmcg. All rights reserved.
//

#include <metal_stdlib>
#include "Shaders.h"
using namespace metal;


typedef struct
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];

    // Since this member does not have a special attribute, the rasterizer
    // interpolates its value with the values of the other triangle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    float4 color;

} RasterizerData;

/* device indicates in what address space of the GPU should the *vertices be placed in. The two options are device (read-write address space) and constant (read-only address space). However, semantically and for efficiency one should use device for data which will be accessed differently by each vertex (this is our case, we have a different vertex ID for each vertex) and use constant for data which all vertices will use in the same way. */
/* Metal uses the [[...]] syntax to specify Metal specific annotations. We said that we want one parameter to be the vertex buffer, which means that Metal has to call this function and pass the vertex buffer as the first argument. But Metal does not know by itself which parameter of the vertex shader function it should pass the vertex buffer to, so writing [[buffer(0)]] is how we tell Metal that this specific parameter *vertices is where is should pass the first buffer. Note that the 0 here corresponds directly to the index: 0
 Similarly, Metal needs to pass the vertex ID to the vertex shader function, so writing [[vertex_id]] on the second parameter tells Metal where to pass the vertex ID  */
vertex RasterizerData vertex_shader(const device Vertex *vertices [[ buffer(0) ]], uint vertex_id [[ vertex_id ]]) {
     //RasterizerData( vertices[vertex_id], float4(1))
    
    RasterizerData out = RasterizerData();
    out.position = float4(- vertices[vertex_id].position.xyz, 1);
    out.color = vertices[vertex_id].color;
    return out;
}

fragment float4 fragment_shader(RasterizerData interpolated [[stage_in]]) {
    return interpolated.color;
}
