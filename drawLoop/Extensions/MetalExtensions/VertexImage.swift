//
//  VertexImage.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 09/09/22.
//


import Foundation
import Metal
import MetalKit
import simd

/** Data structure that goes directly to the shader functions. Do not change the order of the variables without
 also changing the order int he Shader.metal file. */
struct VertexImage: Codable {
    
    // MARK: Variables (IMPORTANT: DO NOT change the order of these variables)
    
    var position: SIMD2<Float>
    
    var point_size: Float
    
    var color: SIMD4<Float>
    
    var rotation: Float
    
    
    
    // MARK: Initialization
    
    init(position: CGPoint, size: CGFloat = 40.0, color: UIColor, rotation: CGFloat) {
        let x = Float(position.x)
        let y = Float(position.y)
        let rgba = color.rgba
        let toFloat = [rgba.red, rgba.green, rgba.blue, rgba.alpha].map { a -> Float in
            return Float(a)
        }
        
        self.position = SIMD2<Float>(x: x, y: y)
        self.point_size = Float(size)
        self.color = SIMD4<Float>(x: toFloat[0], y: toFloat[1], z: toFloat[2], w: toFloat[3])
        self.rotation = Float(rotation)
    }
}
