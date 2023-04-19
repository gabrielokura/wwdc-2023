//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 09/04/23.
//

import Foundation
import SpriteKit

class MenuScreen: SKScene, SKSceneDelegate {
    weak var gameManager: GameManager?
    
    static func buildScene(_ gameManager: GameManager!) -> MenuScreen{
        let scene = MenuScreen(fileNamed: "MenuScreen")!
        scene.gameManager = gameManager
        scene.scaleMode = .fill
        return scene
    }
    
    var ligths: SKSpriteNode!
    var aliens: SKSpriteNode!
    var gameTitle: SKSpriteNode!
    var spaceship: SKSpriteNode!
    var startText: SKSpriteNode!
    var loadingText: SKLabelNode!
    var orientationHint: SKSpriteNode!
    var timer: Timer!
    var canStartGame = false
    var orientationValue = 0
    var isLoading = false
    
    var startGameSound = SKAction.playSoundFileNamed("start_game_sound.wav", waitForCompletion: false)
    var insertCoinSound = SKAction.playSoundFileNamed("insert_coin_sound.wav", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        self.delegate = self
        orientationValue = UIDevice.current.orientation.rawValue
        print("orientation \(orientationValue)")
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        setupNodes()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setupNodes() {
        loadingText = childNode(withName: "loading_text") as? SKLabelNode
        aliens = childNode(withName: "aliens") as? SKSpriteNode
        startText = childNode(withName: "start_text") as? SKSpriteNode
        gameTitle = childNode(withName: "title") as? SKSpriteNode
        spaceship = childNode(withName: "spaceship") as? SKSpriteNode
        orientationHint = childNode(withName: "orientation_hint") as? SKSpriteNode
        
        hideSecondaryNodes(true)
        
        if orientationValue == 4 || orientationValue == 3{
            startGame()
        }
        
        self.run(startGameSound)
        
    }
    
    @objc func didChangeDeviceOrientation() {
        
        let newValue = UIDevice.current.orientation.rawValue
        if newValue == 0 {
            return
        }
        
        orientationValue = newValue
        print("orientation \(orientationValue)")
        
        if ( orientationValue == 4 || orientationValue == 3) && !isLoading{
            startGame()
        }
    }
    
    func startGame() {
        orientationHint.isHidden = true
        isLoading = true
        setupLoadingAnimation()
        setupZoomAnimation()
    }
    
    func hideSecondaryNodes(_ isHidden: Bool) {
        startText.isHidden = isHidden
        gameTitle.isHidden = isHidden
        spaceship.isHidden = isHidden
    }
    
    func setupLoadingAnimation() {
        let timeInterval = TimeInterval(0.3)
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateLoadingText), userInfo: nil, repeats: true)
        
        let waitAction = SKAction.wait(forDuration: TimeInterval(1.5))
        let disappearAnimation = SKAction.fadeAlpha(to: 0, duration: TimeInterval(0))
        let appearAnimation = SKAction.fadeAlpha(to: 1, duration: TimeInterval(0))
        
        let sequence = SKAction.sequence([disappearAnimation, SKAction.wait(forDuration: TimeInterval(0.1)), appearAnimation, waitAction])
        aliens.run(SKAction.repeatForever(sequence))
        
    }
    
    func setupZoomAnimation() {
        print("zooming")
        
        let waitAction = SKAction.wait(forDuration: TimeInterval(3))
        let zoomInXAction = SKAction.scaleX(to: 0.55, duration: TimeInterval(1))
        let zoomInYAction = SKAction.scaleY(to: 0.55, duration: TimeInterval(1))
        
        let group = SKAction.group([zoomInXAction, zoomInYAction])
        let sequence = SKAction.sequence([waitAction, group])
        
        let cameraNode = childNode(withName: "camera") as! SKCameraNode
        
        print("camera node: \(cameraNode)")
        cameraNode.run(sequence) {
            self.showMenuItens()
        }
    }
    
    func showMenuItens() {
        loadingText.removeFromParent()
        aliens.removeFromParent()
        hideSecondaryNodes(false)
        canStartGame = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchDown(pos: touch.location(in: self))
        }
    }
    
    func touchDown (pos: CGPoint) {
        
        if !orientationHint.isHidden {
            orientationHint.isHidden = true
            setupLoadingAnimation()
            setupZoomAnimation()
            return
        }
        
        if canStartGame {
            self.run(insertCoinSound)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: { // remove/replace ship after half a second to visualize collision
                self.gameManager?.goToScene(.spaceInvaders)
            })
            
        }
    }
    
    var counter = 0
    @objc func updateLoadingText() {
        switch counter {
        case 1:
            loadingText.text = "Loading ."
        case 2:
            loadingText.text = "Loading .."
        case 3:
            loadingText.text = "Loading ..."
        default:
            loadingText.text = "Loading"
        }
        
        counter += 1
        if counter > 3 {
            counter = 0
        }
    }
}
