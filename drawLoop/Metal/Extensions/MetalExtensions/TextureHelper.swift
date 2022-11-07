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
func resizeImage(image: UIImage, newWidth: CGFloat,newHeight: CGFloat) -> UIImage {


   UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
   let newImage = UIGraphicsGetImageFromCurrentImageContext()
   UIGraphicsEndImageContext()

    return newImage!
}
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
        var ttexture:MTLTexture!
        let textureLoader = MTKTextureLoader(device: device)
        if let img = UIImage(named: "frost.png") {
            let iimg=img.alpha(0.4)
            let temp=resizeImage(image: iimg, newWidth: CGFloat(Int(size.width*2)), newHeight: CGFloat(Int(size.height*2)))
            let cg = temp.cgImage
            print(cg?.alphaInfo,"dsfsdf")
            ttexture = try! textureLoader.newTexture(cgImage: cg!, options: [
                MTKTextureLoader.Option.SRGB : false,
                
                MTKTextureLoader.Option.textureStorageMode: MTLStorageMode.shared.rawValue,
                

            ])
        }
//        let textureDesc = MTLTextureDescriptor()
//        textureDesc.width = Int(size.width*2)
//        textureDesc.height = Int(size.height*2)
//        print("HEIGHT AND WIDTH ARE",Int(size.height*2),Int(size.width*2))
//        textureDesc.pixelFormat = .bgra8Unorm
//        textureDesc.usage = [.renderTarget,.shaderRead]
//        guard let texture = device.makeTexture(descriptor: textureDesc) else {
//            fatalError("Unable to create texture")
//        }
     
        return ttexture
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
