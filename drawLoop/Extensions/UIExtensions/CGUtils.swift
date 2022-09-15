//
//  CGUtils.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 12/09/22.
//

#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif

extension CGRect {
    func aspectFitted(inside maxRect:CGRect)-> CGRect {
        let originalAspectRatio = self.size.width / self.size.height;
        let maxAspectRatio = maxRect.size.width / maxRect.size.height;

        var newRect = maxRect;
        if (originalAspectRatio > maxAspectRatio) { // scale by width
            newRect.size.height = maxRect.size.width * self.size.height / self.size.width;
            newRect.origin.y += (maxRect.size.height - newRect.size.height)/2.0;
        } else {
            newRect.size.width = maxRect.size.height  * self.size.width / self.size.height;
            newRect.origin.x += (maxRect.size.width - newRect.size.width)/2.0;
        }
        return newRect;
    }
}

extension CGFloat {
    var toFloat: Float {
        return Float(self)
    }

    var toDouble: Double {
        return Double(self)
    }

    var toInt: Int {
        return Int(self)
    }
}

extension CGRect {
    var topLeft: SIMD2<Float> {
        return SIMD2(x:minX.toFloat, y:minY.toFloat)
    }

    var topRight: SIMD2<Float> {
        return SIMD2(x:maxX.toFloat, y:minY.toFloat)
    }

    var bottomLeft: SIMD2<Float> {
        return SIMD2(x:minX.toFloat, y:maxY.toFloat)
    }

    var bottomRight: SIMD2<Float> {
        return SIMD2(x:maxX.toFloat, y:maxY.toFloat)
    }
}

extension CGSize {
    func scaled(to scale: Double) -> CGSize {
        let width = self.width.toDouble*scale
        let height = self.height.toDouble*scale
        return CGSize(width: width, height: height)
    }
}

public extension CGSize
{
    static func scale(_ size : CGSize, _ scale: CGFloat) -> CGSize
    {
        var p = size;
        p.scale(scale: scale);
        return p;
    }

    mutating func scale(scale : CGFloat)
    {
        self.width *= scale;
        self.height *= scale;
    }
}


extension CGPoint {
    var tofloat2: SIMD2<Float> {
        return SIMD2<Float>(self.x.toFloat, self.y.toFloat)
    }

    func distance(to toPoint:CGPoint) -> Float {
        let dx = toPoint.x - self.x
        let dy = toPoint.y - self.y
        return Float(sqrt(dx*dx + dy*dy))
    }

    static func intermediatePoints(start: CGPoint, end:CGPoint) -> [CGPoint] {
        var points = [CGPoint]()
        let distance = start.distance(to: end)
        var count : Int = Int(ceilf(distance))
        count = max(count, 1)
        let countInFloat = CGFloat(1.0)/CGFloat(count);
        for i in 0..<count {
            autoreleasepool {
                let x = start.x + (end.x - start.x) * (CGFloat(i) * countInFloat);
                let y = start.y + (end.y - start.y) * (CGFloat(i) * countInFloat);
                let intermediatePoint = CGPoint(x: x, y: y)
                points.append(intermediatePoint)
            }
        }
        return points
    }
}

extension PlatformColor {
    var toFloat4: SIMD4<Float> {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SIMD4<Float>(red.toFloat, green.toFloat, blue.toFloat, alpha.toFloat)
    }
}
