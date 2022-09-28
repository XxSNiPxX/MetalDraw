//
//  alternateFlowManager.swift
//  drawLoop
//
//  Created by FluidTouch on 28/09/22.



import Foundation
import MetalKit


/*
 - Calculate the points in CGPoints
 
 - Create VertexImage array and keep it ready for the rendering

 */



@objc(alternateFlowManager)
class alternateFlowManager: NSObject {
    var indices: [UInt32] = []
    var vertices: [CGPoint] = []
    var imageVertices: [VertexImage] = []
    var minimumNorm: Float = 1
    var minimumNormKeyVertex: Float = 0
    var minimumAngle: Float = 0.15
    var interpolationDivider: Float = 1 // Higher -> use more RAM
    private var _keyVertices: [CGPoint] = []
    private var _interpolationPipelineState: MTLComputePipelineState!
    private var _device: MTLDevice!
    private var _lastVertex: VertexImage?
    private var config:AppConfig?
    private var size:Float?
    
    override init() {
        super.init()
        config=AppConfig()
        stop()

    }
    
    func addKeyVertex(_ vertex: CGPoint,point_size:Float) {
//         imageVertices.append(vertex)
//        return;
        let normOkay = true
        
        size=point_size
        if normOkay {
            appendAndMaintainArrayLength(&_keyVertices, vertex, length: 4)
            if((config?.catmullLogic) != false){
                if (_keyVertices.count >= 3) {
                    let interpolationB = getKeyVertex(1)!
                    let interpolationA = getKeyVertex(2) ?? interpolationB
                    let beforeInterpolation = getKeyVertex(3) ?? vertex
    //                add(vertex,vertex.point_size)
                                        interpolateCatmullRom(
                                            beforeInterpolation,
                                            interpolationA,
                                            interpolationB,
                                            vertex
                                        )
                }
            }else{
                add(vertex)
            }
   
            
        }
    }
    
    func clearInit(length:Int){
        if length != imageVertices.count {
            print("😆",length,imageVertices.count,"LENGTH IUSS")
        }
       // TODO: identify the vertices, which got rendered and cleared.
        imageVertices=imageVertices.suffix(45)
    }
    
    
//    func pendingPoints() -> [VertexImage] {
//
//    }
    
    func stop() {


        imageVertices.removeAll()
        _keyVertices.removeAll()
        _lastVertex = nil
    }
    
    private func add(_ vertex: CGPoint,_ index: Int? = nil) {
        let normOkay = true
        let angleOkay = true
       
        
//

        if normOkay && angleOkay {
     
            if _lastVertex != nil && imageVertices.count>3{
                // Join triangle
//                print("inside not nill last vertx")
                indices.append(contentsOf: [
                    UInt32(imageVertices.count),
                ])
            }
            
            if
                let previousVertex = getVertex(2),
                let concernedVertex = getVertex(1)
            {

      
                //State machine must start here
                let cg=CGPoint(x: CGFloat(vertex.x), y:CGFloat(vertex.y))
                
                
                //This is triangle based logic handling
                _lastVertex = VertexImage(
                    position: cg,
                    size: CGFloat(size!),
                    color: UIColor.red,
                    rotation: 0
                )
                addImageVertices(_lastVertex! )

//                if newFlow {
//                    // ...
//                }
            }
            
            appendAndMaintainArrayLength(&_keyVertices, vertex, length: 3)


        }
    }
    
    private func appendAndMaintainArrayLength<T>(_ array: inout [T], _ element: T, length: Int) {
        if array.count >= length {
            array.remove(at: 0)
        }
        array.append(element)
    }
    
    private func addImageVertices(_ vertice: VertexImage, _ indexes: [Int] = []) {
        indices.append(contentsOf: indexes.map{ UInt32($0) })
        imageVertices.append(vertice)
//        print(imageVertices.count)
    }
    
    private func getKeyVertex(_ indexFromEnd: Int) -> CGPoint? {
        return getArraySafe(_keyVertices, indexFromEnd)
    }
    
    private func getVertex(_ indexFromEnd: Int) -> VertexImage? {
        let element = getArraySafe(imageVertices, indexFromEnd)
        return element != nil ? element : nil
    }
    
    private func getArraySafe<T>(_ array: [T], _ indexFromEnd: Int) -> T? {
        let index = array.count - (indexFromEnd + 1)
        if array.count >= index && index >= 0 {
            return array[index]
        }
        
        return nil
    }
    
    private func interpolateCatmullRom(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) {
        let vBC = VectorCG(p1, p2)
        let vBA = VectorCG(p1, p0)
        let angle = vBA.angleDeg(with: vBC)

        // More points when the angle is bigger
        let to = ((vBC.norm / interpolationDivider) * (1 + angle / 10)).rounded(.up)
        print(to,"TO IS")
        var i: Float = to
        while i >= 0 {
            let t = 1 - i / to
            
            let x = catmullRom(t, Float(p0.x), Float(p1.x), Float(p2.x), Float(p3.x))
            let y = catmullRom(t, Float(p0.y), Float(p1.y), Float(p2.y), Float(p3.y))
            let cg=CGPoint(x: CGFloat(x), y:CGFloat(y))
      

//            print(vertex,i)
                    
            add(cg)

            i -= 1
        }
    }
    
    private func catmullRom(_ t: Float, _ p0: Float, _ p1: Float, _ p2: Float, _ p3: Float) -> Float {
        let a = 3 * p1 - p0 - 3 * p2 + p3
        let b = 2 * p0 - 5 * p1 + 4 * p2 - p3
        let c = (p2 - p0) * t
        let d = 2 * p1
        let final = (a * pow(t, 3) + b * pow(t, 2) + c + d)
        return 0.5 * final
    }
}


//func norm(startVertex:VertexImage,endVertex:VertexImage) -> Float {
//    let x = endVertex.position.x - startVertex.position.x
//    let y = endVertex.position.y - startVertex.position.y
//    return sqrt(pow(x, 2) + pow(y, 2))
//}
