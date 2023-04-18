//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 15/04/23.
//

import SceneKit

class ARAlien: SCNNode {
    override init() {
        super.init()
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionCategory.alien.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.alienBullet.rawValue
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(.red)
        self.geometry?.materials  = [material, material, material, material, material, material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
