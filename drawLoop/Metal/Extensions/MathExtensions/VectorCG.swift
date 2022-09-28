//
//  VectorCG.swift
//  drawLoop
//
//  Created by FluidTouch on 28/09/22.
//



import Foundation
import UIKit

class VectorCG {
    var startVertex: CGPoint? {
        didSet {
            computePos()
        }
    }
    var endVertex: CGPoint? {
        didSet {
            computePos()
        }
    }
    var x: Float!
    var y: Float!
    
    var norm: Float {
        return sqrt(pow(x, 2) + pow(y, 2))
    }
    
    init(_ startVertex: CGPoint, _ endVertex: CGPoint) {
        self.startVertex = startVertex
        self.endVertex = endVertex
        computePos()
    }
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    func angle(with: VectorCG) -> Float {
        return acos(abs(scalarProduct(with: with) / (norm * with.norm)))
    }
    
    func angleDeg(with: VectorCG) -> Float {
        return 180 / Float.pi * angle(with: with)
    }
    
    func scalarProduct(with: VectorCG) -> Float {
        return x * with.x + y * with.y
    }
    
    func normalize() -> VectorCG {
        let out = VectorCG(x, y)
        out.x /= norm
        out.y /= norm
        return out
    }
    
    func rotatePerp() -> VectorCG {
        let out = VectorCG(x, y)
        out.x = -y
        out.y = x
        return out
    }
    
    func addVector(_ vector: VectorCG) -> VectorCG {
        let out = VectorCG(x, y)
        out.x += vector.x
        out.y += vector.y
        return out
    }
    
    func substractVector(_ vector: VectorCG) -> VectorCG {
        let out = VectorCG(x, y)
        out.x -= vector.x
        out.y -= vector.y
        return out
    }
    
    func addXY(_ number: Float) -> VectorCG {
        let out = VectorCG(x, y)
        out.x += number
        out.y += number
        return out
    }
    
    func substractXY(_ number: Float) -> VectorCG {
        return addXY(-number)
    }
    
    func scale(_ by: Float) -> VectorCG {
        let out = VectorCG(x, y)
        out.x *= by
        out.y *= by
        return out
    }
    
    func reverse() -> VectorCG {
        return scale(-1)
    }
    
    func divide(_ by: Float) -> VectorCG{
        return scale(1 / by)
    }
    
    func copy() -> VectorCG {
        return VectorCG(x, y)
    }
    
//    func toVertexImage() -> VertexImage {
//        return VertexImage(position: [
//            x,
//            y
//        ])
//    }
    
    private func computePos() {
        if startVertex != nil && endVertex != nil {
            x = Float(endVertex!.x - startVertex!.x)
            y = Float(endVertex!.y - startVertex!.y)
        }
    }
}
