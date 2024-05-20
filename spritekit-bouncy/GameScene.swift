//
//  GameScene.swift
//  spritekit-bouncy
//
//  Created by Andre LaBranche on 5/19/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var mousePos : CGPoint = CGPoint(x: 0, y: 0)

    private var lastUpdateTime : TimeInterval = 0
    //private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var ballNode : SKShapeNode?
    private var cameraNode : SKCameraNode?
    //private var sceneAnchorPoint : CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    override func sceneDidLoad() {
        
//        cameraNode = SKCameraNode()
//        self.addChild(cameraNode!)
        
        // scene background should be transparent
        self.backgroundColor = SKColor.clear
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
        
        // set up physics
        //self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        self.physicsWorld.contactDelegate = self
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        // Create a 'ball' node from a circle shape node. We will copy this object to
        // spawn instances of it in response to input or game events. The ball should
        // be small, solid background color, configured as a kinematic physics
        // body with a circular collision boundary
        let ballRadius = 10.0
        self.ballNode = SKShapeNode.init(circleOfRadius: CGFloat(ballRadius))
        if let ballNode = self.ballNode {
            ballNode.fillColor = SKColor.red
            ballNode.strokeColor = SKColor.black
            ballNode.lineWidth = 1.0
            ballNode.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(ballRadius))
            ballNode.physicsBody?.isDynamic = true
            // balls should collide with the edge loop but not each other
            ballNode.physicsBody?.categoryBitMask = 0x1
            ballNode.physicsBody?.collisionBitMask = 0x2
            ballNode.physicsBody?.contactTestBitMask = 0x2
            ballNode.physicsBody?.affectedByGravity = false
            // maximum elasticity, no friction
            ballNode.physicsBody?.restitution = 1.0
            ballNode.physicsBody?.friction = 0.0
         }
        
        // Create an edge loop physics body based on the viewable portion of the scene according to
        // our camera
//        let cameraRect = self.cameraNode?.frame
//        let edgeBody = SKPhysicsBody(edgeLoopFrom: cameraRect!)
//        self.physicsBody = edgeBody
    }
    
    override func didMove(to view: SKView) {
        self.cameraNode = SKCameraNode()
        if let camera = self.cameraNode {
            
            // Position the camera at the center of the scene
            camera.position = CGPoint(x: 0.0, y: 0.0)
            
            // Create the edge loop around the visible area
            createEdgeLoop()
        }
    }
     
     func createEdgeLoop() {
         // Calculate the visible area based on the camera
         let visibleRect = calculateVisibleRect()
         
         // Create the edge loop
         let edgeLoop = SKPhysicsBody(edgeLoopFrom: visibleRect)
         self.physicsBody = edgeLoop
     }
     
     func calculateVisibleRect() -> CGRect {
         guard let camera = self.camera else {
             return self.frame
         }
         
         // Determine the scale of the camera
         let scale = camera.xScale
         
         // Calculate the visible width and height
         let visibleWidth = self.size.width / scale
         let visibleHeight = self.size.height / scale
         
         // Calculate the visible rect based on the camera's position
         let visibleRect = CGRect(
             x: camera.position.x - visibleWidth / 2,
             y: camera.position.y - visibleHeight / 2,
             width: visibleWidth,
             height: visibleHeight
         )
         
         return visibleRect
     }
    
    // spawn a ball
    func spawnBall(fromEvent e: NSEvent) {
        // spawn the ball at the center of the camera's view
        let spawnLocation = CGPoint(x: 0.0, y: 0.0)
        // calculate the velocity's angle from mousePos relative to the scene center
        // get the mouse position from the view
        let mousePos = view?.window?.mouseLocationOutsideOfEventStream
        // convert mousePos to scene coordinates
        let scenePos = self.convertPoint(fromView: mousePos!)
        let dx = spawnLocation.x - scenePos.x
        let dy = spawnLocation.y - scenePos.y
        // calculate the velocity's magnitude based on mousePos's distance from the scene center
        let distance = sqrt(dx*dx + dy*dy)
        let scaled_distance = distance / 100.0
        let velocity = CGVector(dx: dx * scaled_distance, dy: dy * scaled_distance)
        //print("p: \(scenePos) d: \(distance) v: \(velocity)")
        // create a new ball node
        let newBall = self.ballNode?.copy() as! SKShapeNode
        newBall.position = spawnLocation
        newBall.physicsBody?.velocity = velocity
        // balls should despawn after 2 seconds
        let despawn = SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                         SKAction.removeFromParent()])
        newBall.run(despawn)
        self.addChild(newBall)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }

    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            // spawn a ball
            self.spawnBall(fromEvent: event)
        default:
            print("fall through: \(event.characters!) \(event.keyCode)")
            //print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
    
    // if the scene is resized, update the edge loop
    override func didChangeSize(_ oldSize: CGSize) {
        createEdgeLoop()
    }
}
