//
//  Vector.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 12/09/22.
//
//


import Foundation
import UIKit

class Vector {
    var startVertex: VertexImage? {
        didSet {
            computePos()
        }
    }
    var endVertex: VertexImage? {
        didSet {
            computePos()
        }
    }
    var x: Float!
    var y: Float!
    
    var norm: Float {
        return sqrt(pow(x, 2) + pow(y, 2))
    }
    
    init(_ startVertex: VertexImage, _ endVertex: VertexImage) {
        self.startVertex = startVertex
        self.endVertex = endVertex
        computePos()
    }
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    func angle(with: Vector) -> Float {
        return acos(abs(scalarProduct(with: with) / (norm * with.norm)))
    }
    
    func angleDeg(with: Vector) -> Float {
        return 180 / Float.pi * angle(with: with)
    }
    
    func scalarProduct(with: Vector) -> Float {
        return x * with.x + y * with.y
    }
    
    func normalize() -> Vector {
        let out = Vector(x, y)
        out.x /= norm
        out.y /= norm
        return out
    }
    
    func rotatePerp() -> Vector {
        let out = Vector(x, y)
        out.x = -y
        out.y = x
        return out
    }
    
    func addVector(_ vector: Vector) -> Vector {
        let out = Vector(x, y)
        out.x += vector.x
        out.y += vector.y
        return out
    }
    
    func substractVector(_ vector: Vector) -> Vector {
        let out = Vector(x, y)
        out.x -= vector.x
        out.y -= vector.y
        return out
    }
    
    func addXY(_ number: Float) -> Vector {
        let out = Vector(x, y)
        out.x += number
        out.y += number
        return out
    }
    
    func substractXY(_ number: Float) -> Vector {
        return addXY(-number)
    }
    
    func scale(_ by: Float) -> Vector {
        let out = Vector(x, y)
        out.x *= by
        out.y *= by
        return out
    }
    
    func reverse() -> Vector {
        return scale(-1)
    }
    
    func divide(_ by: Float) -> Vector {
        return scale(1 / by)
    }
    
    func copy() -> Vector {
        return Vector(x, y)
    }
    
//    func toVertexImage() -> VertexImage {
//        return VertexImage(position: [
//            x,
//            y
//        ])
//    }
    
    private func computePos() {
        if startVertex != nil && endVertex != nil {
            x = endVertex!.position.x - startVertex!.position.x
            y = endVertex!.position.y - startVertex!.position.y
        }
    }
}
