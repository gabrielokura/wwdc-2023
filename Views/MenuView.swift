//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 16/04/23.
//

import SwiftUI
import SpriteKit

struct MenuView: View {
    let gameManager: GameManager!
    
    init(gameManager: GameManager!) {
        self.gameManager = gameManager
    }
    
    var body: some View {
        VStack {
            SpriteView(scene: MenuScreen.buildScene(gameManager))
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
}
