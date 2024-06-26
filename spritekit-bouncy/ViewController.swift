//
//  ViewController.swift
//  spritekit-bouncy
//
//  Created by Andre LaBranche on 5/19/24.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view should be completely transparent so we see what is behind the window
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .resizeFill
                
                // Present the scene
                if let view = self.skView {
                    view.presentScene(sceneNode)
                    view.ignoresSiblingOrder = true
                    view.showsFPS = true
                    view.showsNodeCount = true
                    view.allowsTransparency = true
                    //view.showsFields = true
                    //view.showsPhysics = true
                }
            }
        }
        // set the mouse position to the mousePos property of the GameScene
//        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) {
//            (event) -> NSEvent? in
//            let mousePos = event.locationInWindow
//            if let scene = self.skView?.scene as? GameScene {
//                //scene.mousePos = scene.convertPoint(fromView: mousePos)
//                // update force field center and region
//                if let forceField = scene.forceField {
//                    forceField.position = scene.convertPoint(fromView: mousePos)
//                    forceField.region = SKRegion(radius: 100.0)
//                }
//            }
//            return event
//        }
        

    }
    
}

