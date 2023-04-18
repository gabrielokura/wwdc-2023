//
//  SpaceInvadersView.swift
//  wwdc-2023-app
//
//  Created by Gabriel Motelevicz Okura on 09/04/23.
//

import SwiftUI
import SpriteKit

struct SpaceInvadersView: View {
    let gameManager: GameManager!
    
    init(gameManager: GameManager!) {
        self.gameManager = gameManager
    }
    
    var body: some View {
        VStack {
            SpriteView(scene: SpaceInvadersScreen.buildScene(gameManager))
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
}
