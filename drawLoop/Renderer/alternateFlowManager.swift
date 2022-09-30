//
//  ImageFlowManager.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 12/09/22.
//
//



import Foundation
import MetalKit


/*
 - Calculate the points in CGPoints
 
 - Create VertexImage array and keep it ready for the rendering

 */



@objc(alternateFlowManager)
class alternateFlowManager: NSObject {
    var indices: [UInt32] = []
    var vertices: [VertexImage] = []
     var imageVertices: [VertexImage] = []
    var minimumNorm: Float = 1
    var minimumNormKeyVertex: Float = 0
    var minimumAngle: Float = 0.15
    var interpolationDivider: Float = 10// Higher -> use more RAM
    private var _keyVertices: [VertexImage] = []
    private var _interpolationPipelineState: MTLComputePipelineState!
    private var _device: MTLDevice!
    private var _lastVertex: VertexImage?
    private var config:AppConfig?
     var llen:Int?

    
    override init() {
        super.init()
        config=AppConfig()
        llen=0
        stop()

    }
    
    func getVertices(counter:Int)->[VertexImage] {
        var verticesToAppend:[VertexImage]=[]
        print((imageVertices.count," "))
        if(counter==0||counter==imageVertices.count){
            return imageVertices

        }else{
            print("COUNTER IS:",counter, "Image vertices are:",imageVertices.count)

            verticesToAppend = Array(imageVertices[counter...imageVertices.count-1])
            print("VERTICS THAT NEED TO BE ADDED ARE:",verticesToAppend.count)
            return verticesToAppend


        }
//        print(start,end,"LENGTH IS",llen,"IMAGE VERTICE SARE")
//        if(start==0&&end==0){
//            return imageVertices
//        }
//        else{
//            if(end==imageVertices.count){
//                return Array([])
//            }else{
//                let tempVert=imageVertices[end...imageVertices.count-1]
//                    return imageVertices
//            }
//
//
//
//
//        }
   
    }
    
    func addKeyVertex(_ vertex: VertexImage) {
        print(vertex.point_size)
        if(vertex.color==UIColor.black){
            print("BLAVK BBY")
        }
//         imageVertices.append(vertex)w1
//        return;
        var normOkay = true
//
        if _keyVertices.count >= 2 {
            print("NORM BETWEEN TWO POIBTS:" ,Vector(getKeyVertex(0)!, vertex).norm)
//                   normOkay = Vector(getKeyVertex(0)!, vertex).norm > minimumNormKeyVertex
               }
        if normOkay {
            appendAndMaintainArrayLength(&_keyVertices, vertex, length: 4)
            if((config?.catmullLogic) != false){
                if (_keyVertices.count >= 3) {
                    let interpolationB = getKeyVertex(1)!
                    let interpolationA = getKeyVertex(2) ?? interpolationB
                    let beforeInterpolation = getKeyVertex(3) ?? vertex
             
    //                add(vertex,vertex.point_size)
                    print("CALCULATING CATMULL")
                                        interpolateCatmullRom(
                                            beforeInterpolation,
                                            interpolationA,
                                            interpolationB,
                                            vertex
                                        )
                }else{
                    if(_keyVertices.count>1){
                        let p1 = getKeyVertex(1)!
                        let p2 = getKeyVertex(2) ?? p1
                        func intermediates(p1:CGPoint, p2:CGPoint, nb_points:Int)->[CGPoint]{
                            var out:[CGPoint] = [];
                            let x_spacing = (p2.x - p1.x) / CGFloat(nb_points + 1)
                            let y_spacing = (p2.y - p1.y) / CGFloat(nb_points + 1)
                       
                                for i in 1...nb_points{
                                    
                                        out.append(CGPoint(x:p1.x+CGFloat(i)*x_spacing,y:p1.y+CGFloat(i)*y_spacing))
                                    
                                }
                            
                            
                            return out
                            
                        }
                        func distanceBetween(point1:CGPoint, point2:CGPoint)->CGFloat {
                            return CGFloat(sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2)));
                        }
                        var cg1 = CGPoint(x:CGFloat(p1.position.x),y:CGFloat(p1.position.y))
                        var cg2 = CGPoint(x:CGFloat(p2.position.x),y:CGFloat(p2.position.y))

                        let kkk=distanceBetween(point1:cg1,point2: cg2)

                        let res=intermediates(p1: cg1, p2: cg2, nb_points:50  )
                        
                        for cg in res{
                            print("GENERATED")
                            _lastVertex = VertexImage(
                                position: cg,
                                size: CGFloat(p2.point_size),
                                color: UIColor.blue,
                                rotation: 0
                            )
                            addImageVertices(_lastVertex! )



                        appendAndMaintainArrayLength(&imageVertices, vertex, length: 3)

                        }
                        
                        
                    }
                    else{
                        add(vertex, vertex.point_size)

                    }
                    
                }
            }else{
                add(vertex, vertex.point_size)
            }
   
            
        }
    }
    
    func clearInit(length:Int){
//        if llen != length {
//            print("😆",llen,imageVertices.count,"LENGTH IUSS")
//        }
       // TODO: identify the vertices, which got rendered and cleared.
//        imageVertices=imageVertices.suffix(0)
//        imageVertices=imageVertices.suffix(4)
//        print(imageVertices.count,"CPUNNTTT")
return
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
//    func pendingPoints() -> [VertexImage] {
//
//    }
    
    func stop() {
        print(llen)
        llen=0
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
            
         

      
                //State machine must start here
                let cg=CGPoint(x: CGFloat(vertex.position.x), y:CGFloat(vertex.position.y))
                
                
                //This is triangle based logic handling
                _lastVertex = VertexImage(
                    position: cg,
                    size: CGFloat(size)+10,
                    color: UIColor.red,
                    rotation: 0
                )
                addImageVertices(_lastVertex! )

//                if newFlow {
//                    // ...
//                }
            

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
        llen=llen!+1
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
        var i: Float = to+1
        while i >= 0 {
            let t = 1 - i / to
            
            let x = catmullRom(t, p0.position.x, p1.position.x, p2.position.x, p3.position.x)
            let y = catmullRom(t, p0.position.y, p1.position.y, p2.position.y, p3.position.y)
            
            var vertex = p1
            vertex.position = [x, y]
//            print(vertex,i)
            if(p3.point_size<=0){
                print("SOME ISSUE")
            }
            add(vertex,p3.point_size)

            i -= 1
        }
        print("CATMULL DONW:",imageVertices.count)
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

