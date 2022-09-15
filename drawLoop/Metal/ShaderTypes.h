//
//  ShaderTypes.h
//  drawLoop
//
//  Created by Rishabh Natarajan on 09/09/22.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h


#import <simd/simd.h>

#ifdef __cplusplus

namespace AAPL
{
    struct constants_t
    {
        simd::float4x4 modelview_projection_matrix;
        simd::float4x4 normal_matrix;
        simd::float4   ambient_color;
        simd::float4   diffuse_color;
        int            multiplier;
    } __attribute__ ((aligned (256)));
}

#endif



#endif /* ShaderTypes_h */
