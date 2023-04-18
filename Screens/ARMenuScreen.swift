//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 17/04/23.
//

import Foundation
import SpriteKit

class ARMenuScreen: SKScene, SKSceneDelegate {
    weak var gameManager: GameManager?
    var canOpenGame = false
    var isOpening = false
    
    static func buildScene(_ gameManager: GameManager!) -> ARMenuScreen{
        let scene = ARMenuScreen(fileNamed: "ARMenuScreen")!
        scene.gameManager = gameManager
        scene.scaleMode = .fill
        return scene
    }
    
    override func didMove(to view: SKView) {
        showDialogue()
    }
    
    func showDialogue() {
        canOpenGame = true
    }
    
    func setupZoomAnimation() {
        print("zooming")
        isOpening = true
        
        let waitAction = SKAction.wait(forDuration: TimeInterval(3))
        let zoomInXAction = SKAction.scaleX(to: 0.05, duration: TimeInterval(1))
        let zoomInYAction = SKAction.scaleY(to: 0.05, duration: TimeInterval(1))
        
        let group = SKAction.group([zoomInXAction, zoomInYAction])
        let sequence = SKAction.sequence([waitAction, group])
        
        let cameraNode = childNode(withName: "camera") as! SKCameraNode
        
        print("camera node: \(cameraNode)")
        cameraNode.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canOpenGame && !isOpening {
            setupZoomAnimation()
        }
    }
}
