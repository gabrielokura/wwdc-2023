//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 16/04/23.
//

import SpriteKit

class ScreenLimit {
    var node: SKShapeNode!
    
    init(node: SKShapeNode!) {
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.categoryBitMask = SceneCollisionCategory.limit
        node.physicsBody?.collisionBitMask = SceneCollisionCategory.alienBullet | SceneCollisionCategory.alien | SceneCollisionCategory.player
        node.physicsBody?.contactTestBitMask = SceneCollisionCategory.alienBullet | SceneCollisionCategory.player
        node.physicsBody?.node?.name = "limit"
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.isDynamic = false
        
        self.node = node
    }
}
