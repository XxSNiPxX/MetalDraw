//
//  View.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 09/09/22.
//


import QuartzCore
import Metal

import UIKit

typealias BaseView = UIView


// rendering delegate (App must implement a rendering delegate that responds to these messages
@available(iOS 13.0, *)
@objc(ViewDelegate)
protocol ViewDelegate: NSObjectProtocol {
    
    // called if the view changes orientation or size, renderer can precompute its view and projection matricies here for example
//    func reshape(_ view: View)
    
    // delegate should perform all rendering here
    func render(_ view: View,imageFlow:FlowManager)
    
//    @available(iOS 13.0, *)
//    func updateFlow(_ flowManager: ImageFlowManager)
    
}

@available(iOS 13.0, *)
@available(iOS 13.0, *)
@objc(View)
class View: BaseView {
    weak var delegate: ViewDelegate?
    
    // view has a handle to the metal device when created
    private(set) var device: MTLDevice!
    
    
    private var _renderPassDescriptor: MTLRenderPassDescriptor?
    
    // set these pixel formats to have the main drawable framebuffer get created with depth and/or stencil attachments
    var depthPixelFormat: MTLPixelFormat = .invalid
    var stencilPixelFormat: MTLPixelFormat = .invalid
    var sampleCount: Int = 0
    private weak var _metalLayer: CAMetalLayer!
    private var _layerSizeDidUpdate: Bool = false
    private var _depthTex: MTLTexture?
    private var _stencilTex: MTLTexture?
    private var _msaaTex: MTLTexture?
    public var finalRenderTexture: MTLTexture!


    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }

    
    private func initCommon() {
            self.isOpaque = true
        self.backgroundColor = UIColor(red: CGFloat(0.65), green: CGFloat(0.65), blue: CGFloat(0.65), alpha: CGFloat(1.0))
            _metalLayer = (self.layer as! CAMetalLayer)

        
        device = MTLCreateSystemDefaultDevice()!
        
        _metalLayer.device          = device
        _metalLayer.pixelFormat     = .bgra8Unorm
        
        // this is the default but if we wanted to perform compute on the final rendering layer we could set this to no
        _metalLayer.framebufferOnly = false
        finalRenderTexture = TextureHelper.createTexture(with: UIScreen.main.bounds.size, device:device)
    }
    

    override func didMoveToWindow() {
        self.contentScaleFactor = self.window!.screen.nativeScale
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initCommon()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.initCommon()
    }
    
    // release any color/depth/stencil resources. view controller will call when paused.
    func releaseTextures() {
        _depthTex   = nil
        _stencilTex = nil
        _msaaTex    = nil
    }
    
    private func setupRenderPassDescriptorForTexture(_ texture: MTLTexture) {
        // create lazily
        if _renderPassDescriptor == nil {
            _renderPassDescriptor = MTLRenderPassDescriptor()
        }
        
        // create a color attachment every frame since we have to recreate the texture every frame
        let colorAttachment = _renderPassDescriptor!.colorAttachments[0]
        colorAttachment?.texture = finalRenderTexture
        
        // make sure to clear every frame for best performance
        colorAttachment?.loadAction = .load
        colorAttachment?.clearColor = MTLClearColorMake(0.65, 0.65, 0.65, 1.0)
        colorAttachment?.storeAction = MTLStoreAction.store
        
//        colorAttachment?.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)

        

    }
    
    // The current framebuffer can be read by delegate during -[MetalViewDelegate render:]
    // This call may block until the framebuffer is available.
    var renderPassDescriptor: MTLRenderPassDescriptor? {
        if self.currentDrawable != nil {
            self.setupRenderPassDescriptorForTexture(finalRenderTexture)
        } else {
            NSLog(">> ERROR: Failed to get a drawable!")
            _renderPassDescriptor = nil
        }
        
        return _renderPassDescriptor
    }
    
    
    //// the current drawable created within the view's CAMetalLayer
    var currentDrawable: CAMetalDrawable? {
        return _metalLayer.nextDrawable()
    }
    
    //// view controller will be call off the main thread

    func display(imageFlow:FlowManager) {
        self.displayPrivate(imageFlow: imageFlow)
    }
    func setupDisplay(){
        return;
    }

    private func displayPrivate(imageFlow:FlowManager) {
        // Create autorelease pool per frame to avoid possible deadlock situations
        // because there are 3 CAMetalDrawables sitting in an autorelease pool.
        
        autoreleasepool{
//            self.delegate?.updateFlow(imageFlow)

            // handle display changes here
            if _layerSizeDidUpdate {
                // set the metal layer to the drawable size in case orientation or size changes
                var drawableSize = self.bounds.size
                
                // scale drawableSize so that drawable is 1:1 width pixels not 1:1 to points
    
                    let screen = self.window?.screen ?? UIScreen.main
                    drawableSize.width *= screen.nativeScale
                    drawableSize.height *= screen.nativeScale
 
                _metalLayer.drawableSize = drawableSize
                
                // renderer delegate method so renderer can resize anything if needed
//                delegate?.reshape(self)
                
                _layerSizeDidUpdate = false
            }
            
            // rendering delegate method to ask renderer to draw this frame's content
            self.delegate?.render(self, imageFlow: imageFlow)
            

        }
    }
    override var contentScaleFactor: CGFloat {
        get {
            return super.contentScaleFactor
        }
        set {
            super.contentScaleFactor = newValue
            _layerSizeDidUpdate = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layerSizeDidUpdate = true
    }

    
}
