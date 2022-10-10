//
//  FlowManager.swift
//  drawLoop
//
//  Created by FluidTouch on 03/10/22.
//

import Foundation
import MetalKit


/*
 - Calculate the points in CGPoints
 
 - Create VertexImage array and keep it ready for the rendering

 */

struct SimpleMovingAverage {
  var period: Int
  var numbers = [Double]()
    mutating func clear(){
        numbers=[]
    }
  mutating func addNumber(_ n: Double) -> Double {
    numbers.append(n)

    if numbers.count > period {
      numbers.removeFirst()
    }

    guard !numbers.isEmpty else {
      return 0
    }
      
    

    return numbers.reduce(0, +) / Double(numbers.count)
  }
}



@objc(FlowManager)
class FlowManager: NSObject {
    var indices: [UInt32] = []
    var vertices: [VertexImage] = []
     var imageVertices: [VertexImage] = []
    var minimumNorm: Float = 1
    var minimumNormKeyVertex: Float = 0
    var minimumAngle: Float = 0.15
    var interpolationDivider: Float = 0.7 // Higher -> use more RAM
    private var _keyVertices: [CGPoint] = []
    private var _interpolationPipelineState: MTLComputePipelineState!
    private var _device: MTLDevice!
    private var _lastVertex: VertexImage?
    private var config:AppConfig?
     var llen:Int?
    private var prevVertex:Float=0
    private let queue = DispatchQueue(label: "ThreadSafeCollection.queue", attributes: .concurrent)
    private var averager:SimpleMovingAverage?
    
    override init() {
        super.init()
        averager = SimpleMovingAverage(period: 200)
        config=AppConfig()
        stop()

    }
    
    func getVertices(counter:Int)->[VertexImage] {
        var verticesToAppend:[VertexImage]=[]
        var tempVertices:[VertexImage]=[]

        print((imageVertices.count," "))
        
        queue.sync { // Read
            tempVertices = imageVertices
          }
        if(counter>tempVertices.count||counter==tempVertices.count){
            return []
        }
        if(counter==0){
            return tempVertices

        }else{
            print("COUNTER IS:",counter, "Image vertices are:",tempVertices.count)

            verticesToAppend = Array(tempVertices[counter...tempVertices.count-1])
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
    
    func addCGPoint(_ cgPoint: CGPoint,_ point_size:Float,color:UIColor) {
        var normOkay = true

        if normOkay {
            appendAndMaintainArrayLength(&_keyVertices, cgPoint, length: 4)
            if((config?.catmullLogic) != false){
                if (_keyVertices.count >= 3) {
                    let interpolationB = getKeyVertex(1)!
                    let interpolationA = getKeyVertex(2) ?? interpolationB
                    let beforeInterpolation = getKeyVertex(3) ?? cgPoint
                                        interpolateCatmullRom(
                                            beforeInterpolation,
                                            interpolationA,
                                            interpolationB,
                                            cgPoint,
                                            point_size,
                                            color: color
    
                                        )
                    
                    
                    
                }else{
                    return
//                    if(_keyVertices.count>1){
//                        let p1 = getKeyVertex(1)!
//                        let p2 = getKeyVertex(2) ?? p1
//                        func intermediates(p1:CGPoint, p2:CGPoint, nb_points:Int)->[CGPoint]{
//                            var out:[CGPoint] = [];
//                            let x_spacing = (p2.x - p1.x) / CGFloat(nb_points + 1)
//                            let y_spacing = (p2.y - p1.y) / CGFloat(nb_points + 1)
//
//                                for i in 1...nb_points{
//
//                                        out.append(CGPoint(x:p1.x+CGFloat(i)*x_spacing,y:p1.y+CGFloat(i)*y_spacing))
//
//                                }
//
//
//                            return out
//
//                        }
//                        func distanceBetween(point1:CGPoint, point2:CGPoint)->CGFloat {
//                            return CGFloat(sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2)));
//                        }
//                        var cg1 = CGPoint(x:CGFloat(p1.position.x),y:CGFloat(p1.position.y))
//                        var cg2 = CGPoint(x:CGFloat(p2.position.x),y:CGFloat(p2.position.y))
//
//                        let kkk=distanceBetween(point1:cg1,point2: cg2)
//
//                        let res=intermediates(p1: cg1, p2: cg2, nb_points:50  )
//
//                        for cg in res{
//                            print("GENERATED")
//                            _lastVertex = VertexImage(
//                                position: cg,
//                                size: CGFloat(p2.point_size),
//                                color: UIColor.blue,
//                                rotation: 0
//                            )
//                            addImageVertices(_lastVertex! )
//
//
//
//                        appendAndMaintainArrayLength(&imageVertices, vertex, length: 3)
//
//                        }
//
//
//                    }
//                    else{
//                        add(vertex, vertex.point_size)
//
//                    }
                    
                }
            }else{
                let temp=UIColor.black
                if(color==temp){
                    print("DATA ENTERED UNSUDE MATEE")
                }

                let vertex=VertexImage(
                    position: cgPoint,
                    size: 50*CGFloat(point_size)  ,//* touch.force,
                    color: color,
                    rotation: 0
                )
                addSingle(vertex,point_size)
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
        averager?.clear()
        prevVertex=0
        queue.sync { // Read
            imageVertices.removeAll()
          }
        _keyVertices.removeAll()
        _lastVertex = nil
    }
    
    private func add(_ vertex: VertexImage ,_ index: Int? = nil) {
        let normOkay = true
        let angleOkay = true
//
        let tempp2=UIColor.black
        let rgba = tempp2.rgba
        let toFloat = [rgba.red, rgba.green, rgba.blue, rgba.alpha].map { a -> Float in
            return Float(a)
        }
        let kk = SIMD4<Float>(x: toFloat[0], y: toFloat[1], z: toFloat[2], w: toFloat[3])

        if(vertex.color==kk){
            print("IT IS BEING ADDED BRO")
        }

        if normOkay && angleOkay {

                //This is triangle based logic handling
                _lastVertex = vertex
                addImageVertices(_lastVertex! )

            

        }
    }
    
    private func addSingle(_ vertex: VertexImage,_ point_size:Float ,_ index: Int? = nil) {
        let normOkay = true
        let angleOkay = true
//

        if normOkay && angleOkay {

                //This is triangle based logic handling
                _lastVertex = vertex
                addImageVertices(_lastVertex! )

            

        }
    }
    
    
    private func appendAndMaintainArrayLength<T>(_ array: inout [T], _ element: T, length: Int) {
        if array.count >= length {
            array.remove(at: 0)
        }
        array.append(element)
    }
    
    private func addImageVertices(_ vertice: VertexImage, _ indexes: [Int] = []) {
        queue.async(flags: .barrier) {
            self.imageVertices.append(vertice)
                }
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
    
    private func interpolateCatmullRom(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint,_ point_size:Float,color:UIColor) {
        
        let vBC = VectorCG(p1, p2)
        let vBA = VectorCG(p1, p0)
        let angle = vBA.angleDeg(with: vBC)
     

        // More points when the angle is bigger
        let to = ((vBC.norm / interpolationDivider) * (1 + angle / 10)).rounded(.up)
        var i: Float = to+1
        while i >= 0 {
            let temp_size=averager!.addNumber(Double(point_size))
            print(point_size,temp_size
                  ,"THE SIZES ARE RESPECTIVELY")
            let t = 1 - i / to
            
            let x = catmullRom(CGFloat(t), p0.x, p1.x, p2.x, p3.x)
            let y = catmullRom(CGFloat(t), p0.y, p1.y, p2.y, p3.y)
            let vertex=VertexImage(
                position: CGPoint(x: x, y: y),
                size: 10 * CGFloat(temp_size)  ,//* touch.force,
                color: color,
                rotation: 0
            )
//            print(vertex,i)
            add(vertex)

            i -= 1
        }
        
        print("CATMULL DONW:",imageVertices.count)
    }
    
    private func catmullRom(_ t: CGFloat, _ p0: CGFloat, _ p1: CGFloat, _ p2: CGFloat, _ p3: CGFloat) -> CGFloat {
        let a = 3 * p1 - p0 - 3 * p2 + p3
        let b = 2 * p0 - 5 * p1 + 4 * p2 - p3
        let c = (p2 - p0) * t
        let d = 2 * p1
        let final = (a * pow(t, 3) + b * pow(t, 2) + c + d)
        return 0.5 * final
    }
    
    func calculatePointSize(size:Float,iteration:Int) -> Float{
        print(size,"SIZE IS")

        if(prevVertex==0){
            prevVertex=size
            return prevVertex
        }
        else{
            let diff=prevVertex-size
            if(abs(diff)>0.5){
                prevVertex=prevVertex+0.1
                print(prevVertex,"INSIDE NEW")
                return size
            }
            else{
              
                return size
            }
        }
    }
    
}


func norm_(startVertex:VertexImage,endVertex:VertexImage) -> Float {
    let x = endVertex.position.x - startVertex.position.x
    let y = endVertex.position.y - startVertex.position.y
    return sqrt(pow(x, 2) + pow(y, 2))
}

