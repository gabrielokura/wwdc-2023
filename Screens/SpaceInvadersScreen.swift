//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 09/04/23.
//

import SpriteKit

class SpaceInvadersScreen: SKScene, SKSceneDelegate, SKPhysicsContactDelegate {
    weak var gameManager: GameManager?
    
    static func buildScene(_ gameManager: GameManager!) -> SpaceInvadersScreen{
        
        let scene = SpaceInvadersScreen(fileNamed: "SpaceInvadersScene")!
        scene.scaleMode = .fill
        scene.gameManager = gameManager
        return scene
    }
    
    var alien1: SKSpriteNode!
    var aliensList = [Alien]()
    let linesNames = ["firstLine", "secondLine", "thirdLine", "fourthLine", "fifthLine"]
    var player: Player!
    var timer: Timer!
    
    var bottomLimit: ScreenLimit!
    var rightLimit: ScreenLimit!
    var leftLimit: ScreenLimit!
    var topLimit: ScreenLimit!
    var dialogues: Dialogues!
    
    var interactionButton: SKSpriteNode!
    var joystick: SKSpriteNode!
    var hintText: SKLabelNode!
    
    var ipadHint: SKSpriteNode!
    
    var killsCounter = 0
    
    var canMoveAliens = false
    var isMovingAliens = false
    
    var orientationValue = 0
    var canFire = true
    
    var scoreText: SKLabelNode!
    var score: Int = 0
    var lives = 99
    var livesText: SKLabelNode!
    
    var gameOverSound = SKAction.playSoundFileNamed("gameover_sound.wav", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        setupAliensList()
        setupLimits()
        setupControllers()
        player = Player(spriteNode: childNode(withName: "player") as? SKSpriteNode)
        
        hintText = childNode(withName: "hint_text") as? SKLabelNode
        scoreText = childNode(withName: "score_text") as? SKLabelNode
        livesText = childNode(withName: "lives_text") as? SKLabelNode
        dialogues = Dialogues(self, hintText)
        setupHintTextAnimation()
        
        self.physicsWorld.contactDelegate = self
        
        orientationValue = UIDevice.current.orientation.rawValue
    }
    
    func setupIpadHint() {
        ipadHint = SKSpriteNode(imageNamed: "turn 1")
        ipadHint.position = CGPoint(x: 0, y: -240)
        
        addChild(ipadHint)
        
        hintText.text = "Move your iPad"
        
        var textures = [SKTexture]()
        
        for i in 1...2 {
            textures.append(SKTexture(imageNamed: "turn \(i)"))
        }
        
        let animation = SKAction.animate(with: textures, timePerFrame: 0.4)
        let sequence = SKAction.sequence([animation, animation, animation])
        
        ipadHint.run(sequence) {
            if self.dialogues.phase == .learningAccelerometer {
                
                self.dialogues.nextDialogue(false)
                self.ipadHint.removeFromParent()
            }
        }
    }
    
    func setupHintTextAnimation() {
        hintText.fontSize = 10
        let waitAction = SKAction.wait(forDuration: TimeInterval(1))
        let disappearAnimation = SKAction.run {
            self.hintText.isHidden = true
        }
        let appearAnimation = SKAction.run {
            self.hintText.isHidden = false
        }
        
        let sequence = SKAction.sequence([disappearAnimation, SKAction.wait(forDuration: TimeInterval(0.1)), appearAnimation, waitAction])
        hintText.run(sequence)
    }
    
    func setupControllers() {
        interactionButton = childNode(withName: "interaction_button") as? SKSpriteNode
        joystick = childNode(withName: "joystick") as? SKSpriteNode
    }
    
    func setupLimits() {
        bottomLimit = ScreenLimit(node: childNode(withName: "bottom_limit") as? SKShapeNode)
        rightLimit = ScreenLimit(node:childNode(withName: "right_limit") as? SKShapeNode)
        leftLimit = ScreenLimit(node: childNode(withName: "left_limit") as? SKShapeNode)
        topLimit = ScreenLimit(node: childNode(withName: "top_limit") as? SKShapeNode)
    }
    
    func setupAliensList() {
        for name in linesNames {
            aliensList.append(contentsOf: setupLine(nodeName: name))
        }
        
        print("Aliens no total: " + aliensList.count.description)
    }
    
    func setupLine(nodeName: String) -> [Alien] {
        
        let node = childNode(withName: nodeName)!
        var alienList = [Alien]()
        
        for alienNode in node.children {
            let newAlien = Alien(spriteNode: alienNode as? SKSpriteNode)
            alienList.append(newAlien)
        }
        
        return alienList
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDown()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchUp()
    }
}

// MARK - Game logic

extension SpaceInvadersScreen {
    func moveAliensDown() {
        
        if isMovingAliens {
           return
        }
        
        isMovingAliens = true
        canMoveAliens = false
        
        for alien in aliensList {
            alien.moveDown()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.isMovingAliens = false
        })
    }
    
    func moveAliens() {
        for alien in aliensList {
            alien.setVelocity()
        }
    }
    
    @objc func newAlienFire() {
        if aliensList.isEmpty {
            return
        }
        
        let random = Int.random(in: 0..<aliensList.count)
        aliensList[random].prepareFire()
    }
    
    func animateJoystick(_ direction: MovingDirection) {
        
        if direction == .idle {
            joystick.texture = SKTexture(imageNamed: "joystick")
            return
        }
        
        joystick.texture = SKTexture(imageNamed: "joystick \(direction.name)")
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if killsCounter >= 35 {
            goToNextMenu()
        }
        
        if player.isMoving {
            animateJoystick(player.direction)
        }
        
        if canMoveAliens {
            moveAliensDown()
        }
        
    }
    
    func goToNextMenu() {
        
        self.run(gameOverSound)
        
        let text = SKLabelNode(fontNamed: "Space-Invaders")
        text.text = "Something went wrong..."
        text.fontSize = 15
        
        let text2 = SKLabelNode(fontNamed: "Space-Invaders")
        text2.text = "Please wait until the game restarts"
        text2.fontSize = 15
        text2.position = CGPoint(x: 0, y: -20)
        
        for alien in aliensList {
            alien.spriteNode.removeFromParent()
        }
        player.spriteNode.removeFromParent()
        self.addChild(text)
        self.addChild(text2)
        
        let zoomInXAction = SKAction.scaleX(to: 0.0001, duration: TimeInterval(1.5))
        let zoomInYAction = SKAction.scaleY(to: 0.0001, duration: TimeInterval(1.5))
        
        let group = SKAction.group([zoomInXAction, zoomInYAction])
        
        let cameraNode = childNode(withName: "camera") as? SKCameraNode
        let sequence = SKAction.sequence([SKAction.wait(forDuration: TimeInterval(4)), group])
        
        if cameraNode == nil {
            print("Camera not Found")
            return;
        }
        
        cameraNode!.run(sequence) {
            self.gameManager?.goToScene(.menuAR)
            self.removeAllChildren()
        }
    }
    
    func startAliensFire() {
        let timeInterval = TimeInterval(0.6)
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(newAlienFire), userInfo: nil, repeats: true)
    }
    
    func touchDown() {
        
        if dialogues.phase == .learningAccelerometer {
            return
        }
        
        if dialogues.phase == .learningShoot {
            dialogues.nextDialogue(true)
            player.fire()
            interactionButton.texture = SKTexture(imageNamed: "button_pressed")
            
            self.run(SKAction.wait(forDuration: TimeInterval(0.5))) {
                self.startGame()
            }
            return
        }
        
        if dialogues.isShowing {
            dialogues.nextDialogue(false)
            if dialogues.phase == .learningAccelerometer {
                setupIpadHint()
                player.startAccelerometers(orientationValue == 4 ? false : true)
            }
            return
        }
        
        // shoot
        self.playerFire()
        interactionButton.texture = SKTexture(imageNamed: "button_pressed")
    }
    
    func touchUp() {
        interactionButton.texture = SKTexture(imageNamed: "button_unpressed")
    }
    
    func startGame() {
        moveAliens()
        startAliensFire()
    }
    
    func playerFire() {
        if !canFire {
            return
        }
        
        player.fire()
        canFire = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.canFire = true
        })
    }
}

extension SpaceInvadersScreen {
    func didBegin(_ contact: SKPhysicsContact) {
        
        // check collision with screen's limits
        if contact.bodyA.categoryBitMask == SceneCollisionCategory.limit {
            collisionWithLimit(contact.bodyB.node)
            return
        } else if contact.bodyB.categoryBitMask == SceneCollisionCategory.limit {
            collisionWithLimit(contact.bodyA.node)
            return
        }
        
        // check collision between bullet and bullet
        if (contact.bodyA.categoryBitMask == SceneCollisionCategory.alienBullet || contact.bodyA.categoryBitMask == SceneCollisionCategory.playerBullet) && (contact.bodyB.categoryBitMask == SceneCollisionCategory.alienBullet || contact.bodyB.categoryBitMask == SceneCollisionCategory.playerBullet) {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            return
        }
        
        // check collision between bullet and bodies
        if contact.bodyA.categoryBitMask == SceneCollisionCategory.alienBullet || contact.bodyA.categoryBitMask == SceneCollisionCategory.playerBullet{
            collisionBulletBody(contact.bodyB.node!, contact.bodyA.node!)
        } else if contact.bodyB.categoryBitMask == SceneCollisionCategory.alienBullet || contact.bodyB.categoryBitMask == SceneCollisionCategory.playerBullet {
            collisionBulletBody(contact.bodyA.node!, contact.bodyB.node!)
        }
        
    }
    
    func collisionBulletBody(_ body: SKNode, _ bullet: SKNode) {
        
        print("collision between bullet and body: \(body.name!) - \(bullet.name!)")
        
        if !bullet.name!.contains("limit") {
            bullet.removeFromParent()
        }
        
        if body.name == "player" {
            player.hitted()
            
            if lives == 0 {
                return
            }
            
            lives -= 1
            livesText.text = "lives: \(lives)"
            
        } else if body.name == "alien" {
            aliensList.removeAll { alien in
                let condition = alien.spriteNode == body as? SKSpriteNode
                if condition {
                    alien.hitted()
                    killsCounter += 1
                    score = score + alien.pontuation
                    scoreText.text = "score: \(score)"
                }
                
                return condition
            }
        }
    }
    
    func collisionWithLimit(_ body: SKNode?) {
        
        print("collision between limit and body: \(body?.name ?? "")")
        
        if body == nil {
            return
        }
        
        if body!.name == "alien" {
            print("Aliens encostaram no limite")
            canMoveAliens = true
            return
        }
        
        if (body!.name?.contains("bullet"))! {
            if !(body!.name?.contains("limit"))! {
                body!.removeFromParent()
            }
        }
    }
}
