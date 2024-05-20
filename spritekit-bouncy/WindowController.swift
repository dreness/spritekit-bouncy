//
//  WindowController.swift
//  spritekit-bouncy
//
//  Created by Andre LaBranche on 5/19/24.
//

import Foundation
import SpriteKit
import GameplayKit

class WindowController : NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // allow window to be transparent
        self.window?.isOpaque = false
        self.window?.backgroundColor = NSColor.clear
        self.window?.titleVisibility = .hidden
        self.window?.titlebarAppearsTransparent = true
        self.window?.styleMask.insert(.fullSizeContentView)
        
        if self.window?.contentView is SKView {
            // Load our GKScene
            if let scene = GKScene(fileNamed: "GameScene") {
                // Get the SKScene from the loaded GKScene
                if (scene.rootNode as! GameScene?) != nil {
                    // let GameScene do its thing
                } else {
                    print("Error: Could not load GameScene")
                }
            }
        }
    }
}
