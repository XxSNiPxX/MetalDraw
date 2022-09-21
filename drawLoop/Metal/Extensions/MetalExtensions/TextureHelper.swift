//
//  TextureHelper.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 12/09/22.
//

import MetalKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

final class TextureHelper {

//    static func texture(with image:UIImage, multiSample: Bool = false) -> MTLTexture {
//        guard let cgImage = image.cgImage else {
//            preconditionFailure("Unable to convert image to cgImage")
//        }
//
//        let texture = createTexture(for:cgImage)
//        return texture
//    }


    static func createTexture(with size: CGSize, device: MTLDevice) -> MTLTexture {
        let textureDesc = MTLTextureDescriptor()
        textureDesc.width = Int(size.width*2)
        textureDesc.height = Int(size.height*2)
        textureDesc.pixelFormat = .bgra8Unorm
        textureDesc.usage = [.renderTarget,.shaderRead]
        guard let texture = device.makeTexture(descriptor: textureDesc) else {
            fatalError("Unable to create texture")
        }
        return texture
    }



}

extension CGImage {

    static func cgImage(for name:String) -> CGImage {
        #if os(macOS)
        guard let image = NSImage(named: name), let imageRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                fatalError("\(name) Image doesn't exist")
        }
        #else
        guard let image = UIImage(named: name), let imageRef = image.cgImage else {
                fatalError("\(name) Image doesn't exist")
        }
        #endif

        return imageRef
    }
}
