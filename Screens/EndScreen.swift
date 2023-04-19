//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 19/04/23.
//

import SpriteKit

class EndScreen: SKScene {
    
    static func buildScene() -> EndScreen{
        let scene = EndScreen(fileNamed: "EndScreen")!
        scene.scaleMode = .fill
        return scene
    }
}
    
