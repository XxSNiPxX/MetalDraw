//
//  UITouch+Extension.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 09/09/22.
//
import Foundation
import UIKit
import Metal
import MetalKit

public extension UITouch {
    
    /** Returns the location of this touch in a view that is based on the Metal coordinate system. */
    func metalLocation(viewportWidth:CGFloat,viewportHeight:CGFloat) -> CGPoint {
        let loc = self.preciseLocation(in: view)
        let _viewportWidth=viewportWidth/2
        let _viewportHeight=viewportHeight/2
        let tem: CGPoint = CGPoint(
            x: loc.x,
            y: loc.y
        )
        let norm: CGPoint = CGPoint(
            x: CGFloat(loc.x / _viewportWidth) - 1,
            y: 1 - CGFloat(loc.y / _viewportHeight)
        )
        return tem
    }
    
    
    
}
