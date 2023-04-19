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
    var isFirstTouch = true
    var dialogueBox: SKSpriteNode!
    
    var tapSound = SKAction.playSoundFileNamed("tap_arcade_sound.wav", waitForCompletion: false)
    var startGame = SKAction.playSoundFileNamed("start_ar_sound.m4a", waitForCompletion: false)
    
    static func buildScene(_ gameManager: GameManager!) -> ARMenuScreen{
        let scene = ARMenuScreen(fileNamed: "ARMenuScreen")!
        scene.gameManager = gameManager
        scene.scaleMode = .fill
        return scene
    }
    
    override func didMove(to view: SKView) {
        dialogueBox = childNode(withName: "dialogue") as? SKSpriteNode
        dialogueBox.isHidden = true
        self.run(startGame)
    }
    
    func setupFirstZoom() {
        print("zooming")
        
        let zoomInXAction = SKAction.scaleX(to: 0.82, duration: TimeInterval(1))
        let zoomInYAction = SKAction.scaleY(to: 0.82, duration: TimeInterval(1))
        let movingAction = SKAction.moveTo(x: 15.5, duration: TimeInterval(1))
        
        let group = SKAction.group([zoomInXAction, zoomInYAction, movingAction])
        
        let cameraNode = childNode(withName: "camera") as! SKCameraNode
        
        print("camera node: \(cameraNode)")
        cameraNode.run(group) {
            self.dialogueBox.isHidden = false
            self.canOpenGame = true
            self.isFirstTouch = false
        }
    }
    func setupZoomAnimation() {
        print("zooming parte 2")
        isOpening = true
        
        let waitAction = SKAction.wait(forDuration: TimeInterval(0.5))
        let zoomInXAction = SKAction.scaleX(to: 0.05, duration: TimeInterval(1))
        let zoomInYAction = SKAction.scaleY(to: 0.05, duration: TimeInterval(1))
        
        let group = SKAction.group([zoomInXAction, zoomInYAction])
        let sequence = SKAction.sequence([waitAction, group])
        
        let cameraNode = childNode(withName: "camera") as! SKCameraNode
        
        print("camera node: \(cameraNode)")
        cameraNode.run(sequence) {
            self.gameManager?.goToScene(.ARGame)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isFirstTouch {
            self.run(tapSound)
            setupFirstZoom()
            return
        }
        
        if canOpenGame && !isOpening {
            self.run(tapSound)
            setupZoomAnimation()
        }
    }
}
