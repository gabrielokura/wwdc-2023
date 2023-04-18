//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 16/04/23.
//

import SceneKit

class Bullet: SCNNode {
    override init () {
        super.init()
        let sphere = SCNSphere(radius: 0.025)
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionCategory.playerBullet.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.alien.rawValue
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        self.geometry?.materials  = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
