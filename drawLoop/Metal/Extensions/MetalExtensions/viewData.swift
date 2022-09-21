//
//  viewData.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 14/09/22.



import Foundation
import Metal
import MetalKit
import simd

/** Data structure that goes directly to the shader functions. Do not change the order of the variables without
 also changing the order int he Shader.metal file. */
struct viewData: Codable {
    
    // MARK: Variables (IMPORTANT: DO NOT change the order of these variables)
    
    var width: Float
    
    var height: Float
    

    
    
    
    // MARK: Initialization
    
    init(width: Float, height: Float) {

        self.width = Float(width)
        self.height = Float(height)
    
    }
}
