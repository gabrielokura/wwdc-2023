//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 09/04/23.
//

import SpriteKit

class Alien {
    let spriteNode: SKSpriteNode!
    
    init(spriteNode: SKSpriteNode!, receiveLimitEvents: Bool) {
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
        spriteNode.physicsBody?.allowsRotation = false
        spriteNode.physicsBody?.affectedByGravity = false
        spriteNode.physicsBody?.categoryBitMask = SceneCollisionCategory.alien
        
        if receiveLimitEvents {
            print("alien recebe eventos de limite")
            spriteNode.physicsBody?.contactTestBitMask = SceneCollisionCategory.limit | SceneCollisionCategory.playerBullet
        } else  {
            spriteNode.physicsBody?.contactTestBitMask =  SceneCollisionCategory.playerBullet
        }
        spriteNode.physicsBody?.collisionBitMask = SceneCollisionCategory.playerBullet
        spriteNode.physicsBody?.node?.name = "alien"
        self.spriteNode = spriteNode
        self.origin = spriteNode.position
        
        self.originalTexture = spriteNode.texture
        shootingTexture = checkType()
    }
    
    var velocity: Double = 60
    let downPositionAdder:CGFloat = -10
    let origin: CGPoint!
    var rightToLeft: Bool = true
    var increases: Int = 0
    
    var shootingTexture: SKTexture!
    var originalTexture: SKTexture!
    
    func checkType() -> SKTexture {
        let currentTexture = spriteNode.texture!
        
        if currentTexture.description.contains("Alien1") {
            return SKTexture(imageNamed: "Alien1_shooting")
        } else if currentTexture.description.contains("Alien2") {
            return SKTexture(imageNamed: "Alien2_shooting")
        } else {
            return SKTexture(imageNamed: "Alien3_shooting")
        }
 
    }
    
    func setVelocity() {
        let direction: Double = rightToLeft ? -1 : 1
        self.spriteNode.physicsBody?.velocity = CGVector(dx: direction*velocity, dy: 0)
    }
    
    func moveDown() {
        
        let currentPosition = self.spriteNode.position
        self.spriteNode.position = CGPoint(x: currentPosition.x, y: currentPosition.y + downPositionAdder)
        rightToLeft.toggle()
        setVelocity()
        
        if increases % 5 == 0 {
            increaseVelocity()
        } else {
            increases += 1
        }

    }
    
    func increaseVelocity() {
        velocity += Double(increases * 10)
    }
    
    func prepareFire() {

        spriteNode.texture = shootingTexture
        let waitAction = SKAction.wait(forDuration: TimeInterval(0.9))
        spriteNode.run(waitAction) {
            self.fire()
        }

    }
    
    
    
    private func fire() {
        let bulletSize = CGSize(width: 30, height: 100)
        let bullet = SKSpriteNode(color: .white, size: bulletSize)
        
        bullet.position = CGPoint(x: 0, y: -spriteNode.size.height)
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = SceneCollisionCategory.alienBullet
        bullet.physicsBody?.contactTestBitMask = SceneCollisionCategory.limit | SceneCollisionCategory.player | SceneCollisionCategory.playerBullet
        bullet.physicsBody?.collisionBitMask = SceneCollisionCategory.limit
        bullet.physicsBody?.node?.name = "alien_bullet"
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.allowsRotation = false
        bullet.physicsBody?.velocity = CGVector(dx: 0, dy: Double(-400))
        
        self.spriteNode.addChild(bullet)
        spriteNode.texture = originalTexture
    }
    
    func hitted() {
        // alien died animation
        let textures: [SKTexture] = [SKTexture(imageNamed: "alien_explosion_1"), SKTexture(imageNamed: "alien_explosion_2"), SKTexture(imageNamed: "alien_explosion_3"), SKTexture(imageNamed: "alien_explosion_4"), SKTexture(imageNamed: "alien_explosion_5")]
        
        let explosionAnimation = SKAction.animate(with: textures, timePerFrame: TimeInterval(0.05))
        let sequence = SKAction.sequence([explosionAnimation, SKAction.removeFromParent()])
        
        spriteNode.physicsBody = nil
        spriteNode.run(sequence)
    }
}
