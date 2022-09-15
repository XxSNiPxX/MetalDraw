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
    
    // Note this method is called from the thread the main game loop is run
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
    func updateFlow(_ flowManager: ImageFlowManager)
    
    @available(iOS 13.0, *)
    func resetFlow(_ flowManager: ImageFlowManager)
    
    @available(iOS 13.0, *)
    func clearFlow(_ flowManager: ImageFlowManager)


}

@available(iOS 13.0, *)
@objc(ViewController)
class ViewController: BaseViewController {
    
    weak var delegate: ViewControllerDelegate?
    
    // the time interval from the last draw
    private(set) var timeSinceLastDraw: TimeInterval = 0.0
    
    // What vsync refresh interval to fire at. (Sets CADisplayLink frameinterval property)
    // set to 1 by default, which is the CADisplayLink default setting (60 FPS).
    // Setting to 2, will cause gameloop to trigger every other vsync (throttling to 30 FPS)
    var interval: Int = 0
    private var _imageFlowManager: ImageFlowManager!

    // app control
    

    private var _displayLink: CADisplayLink?

    // boolean to determine if the first draw has occured
    private var _firstDrawOccurred: Bool = false
    
    private var _timeSinceLastDrawPreviousTime: CFTimeInterval = 0.0
    
    // pause/resume
    private var _gameLoopPaused: Bool = false
    
    // our renderer instance
    private var _renderer: Renderer_!
    
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
//        _displayLink?.frameInterval = interval
        _displayLink?.add(to: RunLoop.main,
            forMode: RunLoop.Mode.default)
    }
    


    
    private func initCommon() {
        _renderer = Renderer_()
        _imageFlowManager = ImageFlowManager()

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
        let renderView = self.view as! View
        renderView.delegate = _renderer
        
        // load all renderer assets before starting game loop
        _renderer.configure(renderView)
        

    }
    
    
    // The main game loop called by the timer above
    @objc func gameloop() {
        
        // tell our delegate to update itself here.
        delegate?.update(self)
        
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
            if((Int(currentTime)%10) == 0){
                print("inside the multiple of 3")
                self.delegate?.clearFlow(_imageFlowManager)

                
            }

            
        }
        
        // display (render)
        
        assert(self.view is View)
        
        // call the display method directly on the render view (setNeedsDisplay: has been disabled in the renderview by default)
        (self.view as! View).display()
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
                delegate?.viewController(self, willPause: pause)
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
        self.dispatchGameLoop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // end the gameloop
        self.stopGameLoop()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let nc = NotificationCenter.default
        nc.post( name: UIApplication.willEnterForegroundNotification, object: nil)
        for touch in touches {
            let point = touch.preciseLocation(in: view);
            let cg=CGPoint(x: CGFloat(point.x), y:CGFloat(point.y))
            let vertex=VertexImage(
                position: cg,
                size: 40 * touch.force,
                color: UIColor.red,
                rotation: 0
            )
            _imageFlowManager.addKeyVertex(vertex)
//            self.delegate?.updateVertices(self,vertex:vertex)
            self.delegate?.updateFlow(_imageFlowManager)

        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let nc = NotificationCenter.default
        nc.post( name: UIApplication.willEnterForegroundNotification, object: nil)
        for touch in touches {
            let point = touch.preciseLocation(in: view);
            let cg=CGPoint(x: CGFloat(point.x), y:CGFloat(point.y))
            let vertex=VertexImage(
                position: cg,
                size: 40 * touch.force,
                color: UIColor.red,
                rotation: 0
            )
            _imageFlowManager.addKeyVertex(vertex)
            self.delegate?.updateFlow(_imageFlowManager)

//            self.delegate?.updateVertices(self,vertex: vertex)

        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let nc = NotificationCenter.default
        nc.post( name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.delegate?.resetVertices(self)
        self.delegate?.resetFlow(_imageFlowManager)
    }
    
}
