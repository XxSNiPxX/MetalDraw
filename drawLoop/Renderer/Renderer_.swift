//
//  Renderer_.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 09/09/22.


import UIKit
import Metal
import simd
import MetalKit


struct VertexInfos {
    let width: Float
    let height: Float
}


private let kInFlightCommandBuffers = 3


@objc(Renderer_)
class Renderer_: NSObject, ViewControllerDelegate, ViewDelegate {
    func render(_ view: View) {
        return
    }
    

    
    // constant synchronization for buffering <kInFlightCommandBuffers> frames
    private var _inflight_semaphore = DispatchSemaphore(value: kInFlightCommandBuffers)
    private var _dynamicConstantBuffer: [MTLBuffer] = []
    private var _verticesInfosBuffer: MTLBuffer!
    private var _imageVertices:[VertexImage]=[]
    // renderer global ivars
    private var _device: MTLDevice?
    private var _commandQueue: MTLCommandQueue?
    private var _defaultLibrary: MTLLibrary?
    private var _pipelineState: MTLRenderPipelineState?
    private var _vertexBuffer: MTLBuffer?
    private var _depthState: MTLDepthStencilState?
    
    // globals used in update calculation
    private var _projectionMatrix: float4x4 = float4x4()
    private var _viewMatrix: float4x4 = float4x4()
    private var _rotation: Float = 0.0
    
    private var _sizeOfConstantT: Int =  MemoryLayout<AAPL.constants_t>.stride
    
    private var texture:MTLTexture!
    internal var textureLoader: MTKTextureLoader!
    private var _verticesImageBuffer:MTLBuffer!
    private var mvpBuffer:MTLBuffer!
    private var finalRenderTexture: MTLTexture!

    private var length: Int = 0
    private var startVertex:Int=0
    private var endVertex:Int=0

    private var bufferPool: LockableBufferPool<MetalBuffer<VertexImage>>?
    private var vertexBuffer: MetalBuffer<VertexImage>?
    
    private var globalHistoryVertice:[VertexImage]=[]

    var counter:Int?

    // this value will cycle from 0 to g_max_inflight_buffers whenever a display completes ensuring renderer clients
    // can synchronize between g_max_inflight_buffers count buffers, and thus avoiding a constant buffer from being overwritten between draws
    private var _constantDataBufferIndex: Int = 0
    
    override init() {
        super.init()
        counter=0
    }
    
    //MARK: Configure
    
    // load all assets before triggering rendering
    @available(iOS 13.0, *)
    func configure(_ view: View) {
        // find a usable Device
        _device = view.device
        guard let _device = _device else {
            fatalError("MTL device not found")
        }
        textureLoader = MTKTextureLoader(device: _device)
        if let img = UIImage(named: "circle.png") {
            guard let cg = img.cgImage else { return }
            texture = try! textureLoader.newTexture(cgImage: cg, options: [
                MTKTextureLoader.Option.SRGB : false,
                MTKTextureLoader.Option.textureStorageMode: MTLStorageMode.shared.rawValue
            ])
        }
        
        // setup view with drawable formats
//        view.depthPixelFormat   = .depth32Float
//        view.stencilPixelFormat = .invalid
        view.sampleCount        = 1
        bufferPool = LockableBufferPool<MetalBuffer<VertexImage>>.init(withCount: 3, factoryFunction: { () -> MetalBuffer<VertexImage> in
            let buffer = MetalBuffer<VertexImage>(vertices: [], mtlDevice: _device)
            return buffer
        })
        
        
        // create a new command queue
        _commandQueue = _device.makeCommandQueue()
        
        _defaultLibrary = _device.makeDefaultLibrary()
        guard _defaultLibrary != nil else {
            NSLog(">> ERROR: Couldnt create a default shader library")
            // assert here becuase if the shader libary isn't loading, nothing good will happen
            fatalError()
        }
        
        guard self.preparePipelineState(view) else {
            NSLog(">> ERROR: Couldnt create a valid pipeline state")
            
            // cannot render anything without a valid compiled pipeline state object.
            fatalError()
        }
        
        let depthStateDesc = MTLDepthStencilDescriptor()
        depthStateDesc.depthCompareFunction = .less
        depthStateDesc.isDepthWriteEnabled = true
        _depthState = _device.makeDepthStencilState(descriptor: depthStateDesc)
        var proj=viewData(width: view.bounds.width.toFloat, height: view.bounds.height.toFloat)
     
        if mvpBuffer == nil {
            mvpBuffer = _device.makeBuffer(bytes: &proj,
                                          length: MemoryLayout<simd_float4x4>.stride,
                                          options: .storageModeShared)
        } else {
            memcpy(mvpBuffer?.contents(), &proj, MemoryLayout<Float>.stride)
        }
        // allocate a number of buffers in memory that matches the sempahore count so that
        // we always have one self contained memory buffer for each buffered frame.
        // In this case triple buffering is the optimal way to go so we cycle through 3 memory buffers
//        var verticesInfos = VertexInfos(width: Float(view.bounds.width), height: Float(view.bounds.height))
//        _verticesInfosBuffer = _device.makeBuffer(
//            bytes: &verticesInfos,
//            length: MemoryLayout<VertexInfos>.size,
//            options: .storageModeShared
//        )
    }
    @available(iOS 13.0, *)
    
    @available(iOS 13.0, *)
    private func preparePipelineState(_ view: View) -> Bool {
        // get the fragment function from the library
        let fragmentProgram = _defaultLibrary?.makeFunction(name: "textured_fragment")
        if fragmentProgram == nil {
            NSLog(">> ERROR: Couldn't load fragment function from default library")
        }
        
        // get the vertex function from the library
        let vertexProgram = _defaultLibrary?.makeFunction(name: "main_vertex")
        if vertexProgram == nil {
            NSLog(">> ERROR: Couldn't load vertex function from default library")
        }
        
        // setup the vertex buffers
//        _vertexBuffer = _device?.makeBuffer(bytes: kCubeVertexData, length: kCubeVertexData.count * MemoryLayout<Float>.size, options: MTLResourceOptions())
//        _vertexBuffer?.label = "Vertices"
//
        // create a pipeline state descriptor which can be used to create a compiled pipeline state object
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineStateDescriptor.label                           = "MyPipeline"
        pipelineStateDescriptor.sampleCount                     = view.sampleCount
        pipelineStateDescriptor.vertexFunction                  = vertexProgram
        pipelineStateDescriptor.fragmentFunction                = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat      = view.depthPixelFormat
        
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperation.add
        pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperation.add
        pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactor.sourceAlpha
        pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactor.one
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        
        // create a compiled pipeline state object. Shader functions (from the render pipeline descriptor)
        // are compiled when this is created unlessed they are obtained from the device's cache
        do {
            _pipelineState = try _device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error as NSError {
            NSLog(">> ERROR: Failed Aquiring pipeline state: \(error)")
            return false
        }
        
        return true
    }
    @available(iOS 13.0, *)
    
    //MARK: Render
    
    @available(iOS 13.0, *)
    func render(_ view: View,imageFlow:alternateFlowManager) {

        let temp=imageFlow.getVertices(counter: counter!)
        if(temp.count>1){
            print(temp,"TEMP IS AFETER CALLING VERICES")

        }
        var verticesToAppend:[VertexImage]=[]
        if(temp==[]){
            return

        }else{
      
            counter=temp.count

        }


        length=temp.count
        print(temp.count,"ELEMNTS TO RENDER ARE")
        guard length > 0 else {
            return
        }
                    _verticesImageBuffer = _device?.makeBuffer(
                        bytes: temp,
                        length: temp.count * MemoryLayout<VertexImage>.stride,
                        options: .cpuCacheModeWriteCombined
                    )
//
//        vertexBuffer = bufferPool?.dequeueItem()
////        print("🔴 DEQUEUE UUID", vertexBuffer!.uuid.suffix(4), "incoming points:", length, vertexBuffer!.count)
//
//        vertexBuffer?.set(temp)
        
        // Allow the renderer to preflight 3 frames on the CPU (using a semapore as a guard) and commit them to the GPU.
        // This semaphore will get signaled once the GPU completes a frame's work via addCompletedHandler callback below,
        // signifying the CPU can go ahead and prepare another frame.
        _ = _inflight_semaphore.wait(timeout: DispatchTime.distantFuture)
        
        // Prior to sending any data to the GPU, constant buffers should be updated accordingly on the CPU.
//        self.updateConstantBuffer()
        
        // create a new command buffer for each renderpass to the current drawable
        let commandBuffer = _commandQueue?.makeCommandBuffer()
        
        // create a render command encoder so we can render into something
        if let renderPassDescriptor = view.renderPassDescriptor {
            let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder?.pushDebugGroup("Boxes")
//            renderEncoder?.setDepthStencilState(_depthState)
            renderEncoder?.setRenderPipelineState(_pipelineState!)
//            renderEncoder?.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)
            renderEncoder?.setVertexBuffer(mvpBuffer, offset: 0, index: 1)

            
//            guard let verticesBuffer = vertexBuffer else { return }

          
                // Set the properties on the encoder for this element and the brush it uses specifically.
            renderEncoder?.setVertexBuffer(_verticesImageBuffer, offset: 0, index: 0)
            renderEncoder?.setFragmentTexture(texture, index: 0)
             func buildSampleState(device: MTLDevice?) -> MTLSamplerState? {
                let sd = MTLSamplerDescriptor()
                sd.magFilter = .linear
                sd.minFilter = .nearest
                sd.mipFilter = .linear
                sd.rAddressMode = .clampToZero
                sd.sAddressMode = .clampToZero
                sd.tAddressMode = .clampToZero
                guard let sampleState = device?.makeSamplerState(descriptor: sd) else {
                    return nil
                }
                return sampleState
            }
            let sampleRate=buildSampleState(device: _device)
            renderEncoder?.setFragmentSamplerState(sampleRate, index: 0)

            // Draw primitives.
            renderEncoder?.drawPrimitives(type:  .point, vertexStart: 0, vertexCount: length)
            renderEncoder?.endEncoding()
            renderEncoder?.popDebugGroup()
            let draww=view.currentDrawable
            FTBlitEncoder.copy(sourceTexture: view.finalRenderTexture!,
                               targetTexture: draww?.texture,
                               commandBuffer: commandBuffer!)
            
            // schedule a present once rendering to the framebuffer is complete
            commandBuffer?.present(draww!)
        }
        
        // call the view's completion handler which is required by the view since it will signal its semaphore and set up the next buffer
        let block_sema = _inflight_semaphore
        commandBuffer?.addCompletedHandler{buffer in
            

//            print("🔴 ENQUEUE UUID", self.vertexBuffer!.uuid.suffix(4), "Length", self.length, "Buffer Count", self.vertexBuffer!.count, "Current Points Count")
//            self.bufferPool?.enqueueItem(self.vertexBuffer!)
    
            self.clearFlow(imageFlow,length: self.counter!)

            
     
            block_sema.signal()
        }
        
        // finalize rendering here. this will push the command buffer to the GPU
        commandBuffer?.commit()
    }
    
    @available(iOS 13.0, *)
    func reshape(_ view: View) {
        // when reshape is called, update the view and projection matricies since this means the view orientation or size changed
    }
    

    //MARK: Update
    

    
    // just use this to update app globals
    @available(iOS 13.0, *)
    func updateFlow(_ flowManager: alternateFlowManager) {
//        if flowManager.imageVertices.count>0{
//////
//            vertexBuffer = bufferPool?.dequeueItem()
//            vertexBuffer?.set(flowManager.imageVertices)
////
////            print(flowManager.imageVertices.count,"vertices are")
//            length=flowManager.imageVertices.count
////            _verticesImageBuffer=vertexBuffer
////            _verticesImageBuffer = _device?.makeBuffer(
////                bytes: flowManager.imageVertices,
////                length: flowManager.imageVertices.count * MemoryLayout<VertexImage>.stride,
////                options: .cpuCacheModeWriteCombined
////            )
//
////            flowManager.clearInit()
//        }
    }
    func updateVertices(_ viewController: ViewController, vertex: Any!) {
        _imageVertices.append(vertex as! VertexImage)
//        if _imageFlowManager.imageVertices.count > 0 {
//        }
        _verticesImageBuffer = _device?.makeBuffer(
            bytes: _imageVertices,
            length: _imageVertices.count * MemoryLayout<VertexImage>.stride,
            options: .cpuCacheModeWriteCombined
        )
    }
    func resetVertices(_ viewController: ViewController) {
//        return
        _imageVertices=[]
        
    }
    func resetFlow(_ flowManager: alternateFlowManager) {
//        return
        flowManager.stop()
        counter=0
        
    }
    
    func clearFlow(_ flowManager: alternateFlowManager,length:Int) {
//        return
        flowManager.clearInit(length: length)
        
    }
  
    @available(iOS 13.0, *)
    func update(_ controller: ViewController) {
        _rotation += Float(controller.timeSinceLastDraw * 50.0)
    }
    
    @available(iOS 13.0, *)
    func viewController(_ viewController: ViewController, willPause pause: Bool) {
        // timer is suspended/resumed
        // Can do any non-rendering related background work here when suspended
    }
    
    
}

