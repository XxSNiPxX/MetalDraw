//
//  FTBlitEncoder.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 12/09/22.

import MetalKit

class FTBlitEncoder: NSObject {

    class func copy(sourceTexture source: MTLTexture!,
                    targetTexture target: MTLTexture!,
                    commandBuffer: MTLCommandBuffer,
                    withOffset offset: CGPoint = CGPoint.zero)
    {
        assert(source.width-Int(offset.x) > 0 && source.height-Int(offset.y) > 0, "FTBlitEncoder copy failed as offset is greater than the size")

        //Render the points into the canvas
        let commandEncoder = commandBuffer.makeBlitCommandEncoder()
        
        let sourceOrigin: MTLOrigin = MTLOriginMake((offset.x < 0) ? -Int(offset.x) : 0 , (offset.y < 0) ? -Int(offset.y) : 0 , 0)
        let destOrigin: MTLOrigin = MTLOriginMake((offset.x > 0) ? Int(offset.x) : 0 , (offset.y > 0) ? Int(offset.y) : 0 , 0)
        var sourceSize: MTLSize = MTLSizeMake((offset.x > 0) ? source.width-Int(offset.x) : source.width + Int(offset.x), (offset.y > 0) ? source.height-Int(offset.y) : source.height + Int(offset.y), 1)
        if(offset == CGPoint.zero) {
            sourceSize = MTLSizeMake(target.width, target.height, 1);
        }
        commandEncoder?.copy(from: source,
                            sourceSlice: 0,
                            sourceLevel: 0,
                            sourceOrigin: sourceOrigin,
                            sourceSize: sourceSize,
                            to: target,
                            destinationSlice: 0,
                            destinationLevel: 0,
                            destinationOrigin: destOrigin)
        
        commandEncoder?.endEncoding()
    }

}
