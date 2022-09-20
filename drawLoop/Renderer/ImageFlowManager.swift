//
//  ImageFlowManager.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 12/09/22.
//
//



import Foundation
import MetalKit

@objc(ImageFlowManager)
class ImageFlowManager: NSObject {
    var indices: [UInt32] = []
    var vertices: [VertexImage] = []
    var imageVertices: [VertexImage] = []
    var minimumNorm: Float = 1
    var minimumNormKeyVertex: Float = 0
    var minimumAngle: Float = 0.15
    var interpolationDivider: Float = 0.9 // Higher -> use more RAM
    private var _keyVertices: [VertexImage] = []
    private var _interpolationPipelineState: MTLComputePipelineState!
    private var _device: MTLDevice!
    private var _lastVertex: VertexImage?
    private var config:AppConfig?

    
    override init() {
        super.init()
        config=AppConfig()
        stop()

    }
    
    func addKeyVertex(_ vertex: VertexImage) {
         imageVertices.append(vertex)
        return;
        let normOkay = true
        

        if normOkay {
            appendAndMaintainArrayLength(&_keyVertices, vertex, length: 4)

            if (_keyVertices.count >= 3) {
                let interpolationB = getKeyVertex(1)!
                let interpolationA = getKeyVertex(2) ?? interpolationB
                let beforeInterpolation = getKeyVertex(3) ?? vertex
//                add(vertex,vertex.point_size)
                if((config?.catmullLogic) != false){
                                    interpolateCatmullRom(
                                        beforeInterpolation,
                                        interpolationA,
                                        interpolationB,
                                        vertex
                                    )
                }else{
                    add(vertex,vertex.point_size)

                }

                
            }
        }
    }
    
    func clearInit(){

        imageVertices=imageVertices.suffix(4)
    }
    
    func stop() {


        imageVertices.removeAll()
        _keyVertices.removeAll()
        _lastVertex = nil
    }
    
    private func add(_ vertex: VertexImage,_ size:Float ,_ index: Int? = nil) {
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
                let cg=CGPoint(x: CGFloat(vertex.position.x), y:CGFloat(vertex.position.y))
                
                
                //This is triangle based logic handling
                _lastVertex = VertexImage(
                    position: cg,
                    size: CGFloat(size),
                    color: UIColor.red,
                    rotation: 0
                )
                addImageVertices(_lastVertex! )

//                if newFlow {
//                    // ...
//                }
            }

            appendAndMaintainArrayLength(&imageVertices, vertex, length: 3)
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
    
    private func getKeyVertex(_ indexFromEnd: Int) -> VertexImage? {
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
    
    private func interpolateCatmullRom(_ p0: VertexImage, _ p1: VertexImage, _ p2: VertexImage, _ p3: VertexImage) {
        let vBC = Vector(p1, p2)
        let vBA = Vector(p1, p0)
        let angle = vBA.angleDeg(with: vBC)

        // More points when the angle is bigger
        let to = ((vBC.norm / interpolationDivider) * (1 + angle / 10)).rounded(.up)
        var i: Float = to
        while i >= 0 {
            let t = 1 - i / to
            
            let x = catmullRom(t, p0.position.x, p1.position.x, p2.position.x, p3.position.x)
            let y = catmullRom(t, p0.position.y, p1.position.y, p2.position.y, p3.position.y)
            
            var vertex = p1
            vertex.position = [x, y]
//            print(vertex,i)
            add(vertex,p3.point_size)

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


func norm(startVertex:VertexImage,endVertex:VertexImage) -> Float {
    let x = endVertex.position.x - startVertex.position.x
    let y = endVertex.position.y - startVertex.position.y
    return sqrt(pow(x, 2) + pow(y, 2))
}
