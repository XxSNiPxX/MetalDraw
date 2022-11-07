//
//  Shader.metal
//  Canvas2
//
//  Created by Adeola Uthman on 1/14/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct Vertex {
    float2 position;
    float point_size;
    float4 color;
    float rotation;
};

struct viewSize{
    float width;
    
    float height;
};

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float4 color;
    float rotation;
};

//float2 cmm(float2 point, viewSize viewSize) {
//    float inverseViewSizeW = 1 / viewSize.width;
//    float inverseViewSizeH = 1 / viewSize.height;
//    float clipX = (2.0f * point.x * inverseViewSizeW) - 1.0f;
//    float clipY = (2.0f * -point.y * inverseViewSizeH) + 1.0f;
//    return float2(clipX, clipY);
//}



vertex VertexOut main_vertex(const device Vertex* verticess [[ buffer(0) ]], unsigned int vid [[ vertex_id ]],constant viewSize &mvp_matrix [[ buffer(1) ]]) {
    VertexOut output;
    

    
    float2 pixelSpacePosition = verticess[vid].position;
    
    float inverseViewSizeW = 1 / mvp_matrix.width;
    float inverseViewSizeH = 1 / mvp_matrix.height;
    float clipX = (2.0f * pixelSpacePosition.x * inverseViewSizeW) - 1.0f;
    float clipY = (2.0f * -pixelSpacePosition.y * inverseViewSizeH) + 1.0f;
    
//    output.position = float4(verticess[vid].position,0,1)*mvp_matrix;
    output.position = float4(float2(clipX, clipY), 0, 1);
    output.point_size = verticess[vid].point_size;
    output.color = verticess[vid].color;
    output.rotation = verticess[vid].rotation;
    
    return output;
};
  
fragment half4 main_fragment(Vertex vert [[stage_in]]) {
    return half4(vert.color);
};

/** Gets the proper texture coordinate given the rotation of the vertex. */
float2 transformPointCoord(float2 pointCoord, float rotation, float2 anchor) {
    float2 point = pointCoord - anchor;
    float x = point.x * cos(rotation) - point.y * sin(rotation);
    float y = point.x * sin(rotation) + point.y * cos(rotation);
    return float2(x, y) + anchor;
}


fragment half4 textured_fragment(Vertex vert [[stage_in]], sampler sampler2D,
                                 texture2d<float> texture [[texture(0)]],
                                 float2 pointCoord [[point_coord]]) {
    
    // TODO: This is just a temporary fix for drawing shapes, since they for some reason don't show up with textures.
    if(vert.rotation == -1) {
        return half4(vert.color);
    }
    
    float2 text_coord = transformPointCoord(pointCoord, vert.rotation, float2(0.5));
    float4 color = float4(texture.sample(sampler2D, text_coord));
    color.a=0.1;
    float4 ret = float4(vert.color.rgb, color.a * vert.color.a * vert.color.a);

    return half4(ret);
}

