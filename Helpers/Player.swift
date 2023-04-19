//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 12/04/23.
//

import SpriteKit
import CoreMotion
import SceneKit

enum MovingDirection {
    case right, left, idle
    
    var name: String {
        get {
            if self == .right {
                return "right"
            }
            
            if self == .left {
                return "left"
            }
            
            return ""
        }
    }
}

class Player {
    let spriteNode: SKSpriteNode!
    private var yDirection: Double = 0
    var isMoving = false
    
    var direction: MovingDirection {
        get {
            
            if yDirection.magnitude < 0.03 {
                return .idle
            }
            
            if yDirection > 0 {
                return .right
            }
            
            if yDirection < 0 {
                return .left
            }
            
            return .idle
        }
    }
    
    init(spriteNode: SKSpriteNode!) {
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
        spriteNode.physicsBody?.allowsRotation = false
        spriteNode.physicsBody?.affectedByGravity = false
        spriteNode.physicsBody?.collisionBitMask = SceneCollisionCategory.limit
        spriteNode.physicsBody?.categoryBitMask = SceneCollisionCategory.player
        spriteNode.physicsBody?.contactTestBitMask = SceneCollisionCategory.limit | SceneCollisionCategory.alienBullet
        spriteNode.physicsBody?.node?.name = "player"
        
        self.spriteNode = spriteNode
        self.origin = spriteNode.position
        
    }
    
    func fire () {
        let bulletSize = CGSize(width: 30, height: 100)
        let bullet = SKSpriteNode(color: .white, size: bulletSize)
        
        bullet.position = CGPoint(x: 0, y: -spriteNode.size.height)
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = SceneCollisionCategory.playerBullet
        bullet.physicsBody?.contactTestBitMask = SceneCollisionCategory.alien | SceneCollisionCategory.limit
        bullet.physicsBody?.collisionBitMask = SceneCollisionCategory.alien | SceneCollisionCategory.limit
        bullet.physicsBody?.node?.name = "player_bullet"
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.allowsRotation = false
        bullet.physicsBody?.velocity = CGVector(dx: 0, dy: Double(700))
        
        self.spriteNode.addChild(bullet)
    }
    
    func hitted() {
        // alien died animation
        let fadeOutAnimation = SKAction.fadeOut(withDuration: TimeInterval(0.1))
        let fadeInAnimation = SKAction.fadeIn(withDuration: TimeInterval(0.1))
        let sequence = SKAction.sequence([fadeOutAnimation, fadeInAnimation, fadeOutAnimation, fadeInAnimation])
        
        spriteNode.physicsBody?.isDynamic = false
        spriteNode.run(sequence) {
            self.spriteNode.physicsBody?.isDynamic = true
        }
    }
    
    let motion = CMMotionManager()
    var timer: Timer!
    let velocity: Double = 1500
    let origin: CGPoint!
    
    func startAccelerometers() {
        isMoving = true
        
        if self.motion.isAccelerometerAvailable {
             self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
             self.motion.startAccelerometerUpdates()

             // Configure a timer to fetch the data.
             self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                   repeats: true, block: { (timer) in
                // Get the accelerometer data.
                if let data = self.motion.accelerometerData {
                   let y = data.acceleration.y

                   // Use the accelerometer data in your app.
                    self.spriteNode.physicsBody?.velocity = CGVector(dx: y * self.velocity, dy: 0)
                    self.yDirection = y
                }
             })

             // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: .default)
          }
    }
}

class ARPlayer: SCNNode {
    override init() {
        super.init()
        let box = SCNBox(width: 0.5, height: 1, length: 0.5, chamferRadius: 0)
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.opacity = 0.01
        
        self.physicsField = SCNPhysicsField.electric()
        self.physicsField?.minimumDistance = 0
        self.physicsField?.strength = 0.01
        
        self.physicsBody?.categoryBitMask = CollisionCategory.player.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.target.rawValue
        self.physicsBody?.collisionBitMask = CollisionCategory.player.rawValue
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "abstract")
        self.geometry?.materials  = [material, material, material, material, material, material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
