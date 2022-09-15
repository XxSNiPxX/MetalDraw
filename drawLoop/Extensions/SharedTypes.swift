//
//  SharedTypes.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 09/09/22.
//

import simd

extension AAPL {
    struct constants_t {
        var modelview_projection_matrix: float4x4
        var normal_matrix: float4x4
        var ambient_color: SIMD4<Float>
        var diffuse_color: SIMD4<Float>
        var multiplier: Int32
        //### to make aligned to 256
        private var _dummy4: Int32 = 0
        private var _dummy8: float2 = float2()
        private var _dummy16: float4 = float4()
        private var _dummy64: float4x4 = float4x4()
    }
}

