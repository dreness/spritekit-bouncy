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
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var ballNode : SKShapeNode?
    //private var sceneAnchorPoint : CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    override func sceneDidLoad() {
        
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.size.width / 2,
                                      y: self.size.height / 2)
        self.addChild(cameraNode)
        self.camera = cameraNode
        
        // scene background should be transparent
        self.backgroundColor = SKColor.clear
        
        // set the anchor point to the center of the scene
        //scene!.anchorPoint = sceneAnchorPoint
        
        // report the position at the center of the view, in view, scene, and world coordinates
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // set up physics
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
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
        let ballRadius = 20.0
        self.ballNode = SKShapeNode.init(circleOfRadius: CGFloat(ballRadius))
        if let ballNode = self.ballNode {
            ballNode.fillColor = SKColor.red
            ballNode.strokeColor = SKColor.black
            ballNode.lineWidth = 1.0
            ballNode.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(ballRadius))
            ballNode.physicsBody?.isDynamic = true
            ballNode.physicsBody?.categoryBitMask = 0b1
            ballNode.physicsBody?.collisionBitMask = 0b1
            ballNode.physicsBody?.contactTestBitMask = 0b1
            ballNode.physicsBody?.affectedByGravity = true
        }
        
        // Create an edge loop physics body that follows the frame of the scene
//        let edgeLoop = SKPhysicsBody(edgeLoopFrom: self.frame)
//        self.physicsBody = edgeLoop
    }
    
    // spawn a ball
    func spawnBall(fromEvent e: NSEvent) {
        // spawn location is the center of the scene, 0,0 in scene coordinates.
        // calculate the center point in view coordinates
        let viewCenter = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        let spawnLocation = viewCenter
        // calculate the velocity's angle from mousePos relative to the scene center
        let dx = mousePos.x - spawnLocation.x
        let dy = mousePos.y - spawnLocation.y
        // calculate the velocity's magnitude based on mousePos's distance from the scene center
        let distance = sqrt(dx*dx + dy*dy)
        let scaled_distance = distance / 100.0
        let velocity = CGVector(dx: dx * scaled_distance, dy: dy * scaled_distance)
        print("p: \(spawnLocation) d: \(distance) v: \(velocity)")
        // create a new ball node
        let newBall = self.ballNode?.copy() as! SKShapeNode
        newBall.position = spawnLocation
        newBall.physicsBody?.velocity = velocity
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
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
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
}
