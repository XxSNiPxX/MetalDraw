//
//  ViewController.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 09/09/22.
//
import UIKit
typealias BaseViewController = UIViewController


// required view controller delegate functions.
@objc(ViewControllerDelegate)
protocol ViewControllerDelegate: NSObjectProtocol {
    
//     Note this method is called from the thread the main game loop is run
    @available(iOS 13.0, *)
    func update(_ controller: ViewController)
    
    // called whenever the main game loop is paused, such as when the app is backgrounded
    @available(iOS 13.0, *)
    func viewController(_ viewController: ViewController, willPause pause: Bool)
    
    @available(iOS 13.0, *)
    func updateVertices(_ viewController: ViewController, vertex:Any!)
    
    @available(iOS 13.0, *)
    func resetVertices(_ viewController: ViewController)
    
    @available(iOS 13.0, *)
    func updateFlow(_ flowManager: FlowManager)
    
    @available(iOS 13.0, *)
    func resetFlow(_ flowManager: FlowManager)
    
    @available(iOS 13.0, *)
    func clearFlow(_ flowManager: FlowManager,length:Int)
//    
    @available(iOS 13.0, *)
    func render(_ view: View)


}

@available(iOS 13.0, *)
@objc(ViewController)
class ViewController: BaseViewController {
    
    weak var delegate: ViewControllerDelegate?
    
    // the time interval from the last draw
    private(set) var timeSinceLastDraw: TimeInterval = 0.0
    private var config:AppConfig!
    // What vsync refresh interval to fire at. (Sets CADisplayLink frameinterval property)
    // set to 1 by default, which is the CADisplayLink default setting (60 FPS).
    // Setting to 2, will cause gameloop to trigger every other vsync (throttling to 30 FPS)
    var interval: Int = 1
    private var _imageFlowManager: FlowManager!

    // app control
    private var sizeOfTouch:CGFloat=CGFloat(1)

    private var _displayLink: CADisplayLink?

    // boolean to determine if the first draw has occured
    private var _firstDrawOccurred: Bool = false
    
    private var _timeSinceLastDrawPreviousTime: CFTimeInterval = 0.0
    
    // pause/resume
    private var _gameLoopPaused: Bool = false
    
    // our renderer instance
    private var _renderer: Renderer_!
    private var renderView: View!

    deinit {
            NotificationCenter.default.removeObserver(self,
                name: UIApplication.didEnterBackgroundNotification,
                object: nil)
            
            NotificationCenter.default.removeObserver(self,
                name: UIApplication.willEnterForegroundNotification,
                object: nil)
            

        if _displayLink != nil {
            self.stopGameLoop()
        }
    }
    

    private func dispatchGameLoop() {
 
        // create a game loop timer using a display link
        _displayLink = UIScreen.main.displayLink(withTarget: self,
            selector: #selector(ViewController.gameloop))
        _displayLink?.frameInterval = interval
        _displayLink?.add(to: RunLoop.main,
            forMode: RunLoop.Mode.default)
    }
    


    
    private func initCommon() {
        _renderer = Renderer_()
        _imageFlowManager = FlowManager()
        config=AppConfig()
        self.delegate = _renderer
            let notificationCenter = NotificationCenter.default
            //  Register notifications to start/stop drawing as this app moves into the background
            notificationCenter.addObserver(self,
                selector: #selector(ViewController.didEnterBackground(_:)),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil)
            
            notificationCenter.addObserver(self,
                selector: #selector(ViewController.willEnterForeground(_:)),
                name: UIApplication.willEnterForegroundNotification,
                object: nil)

        
        interval = 1
    }
    



    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.initCommon()
        
    }

    
    
    // called when loaded from storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.initCommon()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderView = self.view as? View
        renderView.delegate = _renderer

        _renderer.configure(renderView)
        

    }
    
    
    // The main game loop called by the timer above
    @objc func gameloop() {
        
//         tell our delegate to update itself here.
//        delegate?.updateFlow(_imageFlowManager)

        if !_firstDrawOccurred {
            // set up timing data for display since this is the first time through this loop
            timeSinceLastDraw             = 0.0
            _timeSinceLastDrawPreviousTime = CACurrentMediaTime()
            _firstDrawOccurred              = true
        } else {
            // figure out the time since we last we drew
            let currentTime = CACurrentMediaTime()
            
            timeSinceLastDraw = currentTime - _timeSinceLastDrawPreviousTime
            
            // keep track of the time interval between draws
            _timeSinceLastDrawPreviousTime = currentTime
            
//            if((Int(currentTime)%2) == 0){
//                
//                       let nc = NotificationCenter.default
//                        nc.post( name: UIApplication.didEnterBackgroundNotification, object: nil)
//                //        nc.post( name: UIApplication.willEnterForegroundNotification, object: nil)
//
//            }else{
//                let nc = NotificationCenter.default
//                 //nc.post( name: UIApplication.didEnterBackgroundNotification, object: nil)
//                 nc.post( name: UIApplication.willEnterForegroundNotification, object: nil)
//            }

            
        }
        
        // display (render)
        
        assert(self.view is View)
        
        // call the display method directly on the render view (setNeedsDisplay: has been disabled in the renderview by default)
        (self.view as! View).display(imageFlow: _imageFlowManager)
    }
    
    // use invalidates the main game loop. when the app is set to terminate
    func stopGameLoop() {
        if _displayLink != nil {
                _displayLink!.invalidate()

        }
    }
    
    // Used to pause and resume the controller.
    var paused: Bool {
        set(pause) {
            if _gameLoopPaused == pause {
                return
            }
            
            if _displayLink != nil {
                // inform the delegate we are about to pause
//                delegate?.viewController(self, willPause: pause)
                    _gameLoopPaused = pause
                    _displayLink!.isPaused = pause
                    if pause {
                        
                        // ask the view to release textures until its resumed
                        (self.view as! View).releaseTextures()
                    }

                
                
            }
        }
        
        get {
            return _gameLoopPaused
        }
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        self.paused = true
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        self.paused = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nc = NotificationCenter.default
        nc.post( name: UIApplication.willEnterForegroundNotification, object: nil)
        // run the game loop
        if(config.CADisplaylink==true){
            self.dispatchGameLoop()

        }else{
            
            assert(self.view is View)
            (self.view as! View).setupDisplay()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // end the gameloop
        self.stopGameLoop()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        touchFunction(touches, with: event)
        let nc = NotificationCenter.default
        nc.post( name: UIApplication.willEnterForegroundNotification, object: nil)
        var coalescedPoints: [UITouch] = []
        if let coalesced = event?.coalescedTouches(for: touches.first!) {
            coalescedPoints.append(contentsOf: coalesced)
        }
        for touch in coalescedPoints {
      
            if(touch.force>0){
                sizeOfTouch=touch.force
                
            }else{
                print("ITS zero in began",sizeOfTouch)
            }
            let point = touch.preciseLocation(in: view);
            let cg=CGPoint(x: CGFloat(point.x), y:CGFloat(point.y))
            print(cg,"CG IN TOUCHES BEGAN", 90 * sizeOfTouch)

            _imageFlowManager.addCGPoint(cg, Float(sizeOfTouch),color: UIColor.blue)

//            _imageFlowManager.addKeyVertex(cg, point_size: 40 * Float(touch.force))
//            self.delegate?.updateFlow(_imageFlowManager)

//            self.delegate?.updateVertices(self,vertex: vertex)

        }


//        self.delegate?.render(renderView)

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        touchFunction(touches, with: event)
        var coalescedPoints: [UITouch] = []
        if let coalesced = event?.coalescedTouches(for: touches.first!) {
            coalescedPoints.append(contentsOf: coalesced)
        }
        for touch in touches {
            print(touch.force,"FORCE IS")
            if(touch.force==0.0){
                return
            }
            if(touch.force>0){
                sizeOfTouch=min(max(0.4, touch.force), 3)

             
                
            }else{
                print("ITS zero moved",sizeOfTouch)
            }
            let point = touch.preciseLocation(in: view);
            let cg=CGPoint(x: CGFloat(point.x), y:CGFloat(point.y))
            let vertex=VertexImage(
                position: cg,
                size: 50 * sizeOfTouch  ,//* touch.force,
                color: UIColor.yellow,
                rotation: 0
            )

            _imageFlowManager.addCGPoint(cg, Float(sizeOfTouch),color: UIColor.red)


//            _imageFlowManager.addKeyVertex(cg, point_size: 40 * Float(touch.force))
//            self.delegate?.updateFlow(_imageFlowManager)

//            self.delegate?.updateVertices(self,vertex: vertex)

        }


//        self.delegate?.render(renderView)



    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {
                let nc = NotificationCenter.default
        nc.post( name: UIApplication.didEnterkgroundNotification, object: nil)

         touchFunction(touches, with: event)


//        self.delegate?.render(renderView)

//        self.delegate?.resetVertices(self)
        self.delegate?.resetFlow(_imageFlowManager)
     //   self.delegate?.clearFlow(_imageFlowManager)
        
        
    }
    
}

extension ViewController{
    func touchFunction(_ touches: Set<UITouch>, with event: UIEvent?){
        var coalescedPoints: [UITouch] = []
//        if let coalesced = event?.coalescedTouches(for: touches.first!) {
//            coalescedPoints.append(contentsOf: coalesced)
//        }
        
        for touch in touches {
            print(touch.force,"FORCE IS")

            if(touch.force>0){
                sizeOfTouch=touch.force
                
            }else{
                print("ITS zero INSEW ENDEDDD",sizeOfTouch)
            }
            let point = touch.preciseLocation(in: view);
            let cg=CGPoint(x: CGFloat(point.x), y:CGFloat(point.y))
            let vertex=VertexImage(
                position: cg,
                size: 90 * sizeOfTouch  ,//* touch.force,
                color: UIColor.green,
                rotation: 0
            )
            _imageFlowManager.addCGPoint(cg, Float(sizeOfTouch),color: UIColor.green)

//            _imageFlowManager.addKeyVertex(cg, point_size: 40 * Float(touch.force))
//            self.delegate?.updateFlow(_imageFlowManager)

//            self.delegate?.updateVertices(self,vertex: vertex)

        }
    }
}


//Used to trigger pause and unpause
//        let nc = NotificationCenter.default
//        nc.post( name: UIApplication.didEnterBackgroundNotification, object: nil)
//        nc.post( name: UIApplication.willEnterForegroundNotification, object: nil)
