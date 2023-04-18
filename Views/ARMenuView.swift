//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 17/04/23.
//

import SwiftUI
import SpriteKit

struct ARMenuView: View {
    let gameManager: GameManager!
    
    init(gameManager: GameManager!) {
        self.gameManager = gameManager
    }
    
    var body: some View {
        VStack {
            SpriteView(scene: ARMenuScreen.buildScene(gameManager))
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
}
