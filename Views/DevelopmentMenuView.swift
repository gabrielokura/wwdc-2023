//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 09/04/23.
//

import SwiftUI
import SpriteKit

struct MenuViewDev: View {
    let gameManager: GameManager!
    
    init(gameManager: GameManager!) {
        self.gameManager = gameManager
    }
    
    var body: some View {
        VStack {
            Text("My WWDC 2023 app")
                .padding(.top)
            List {
                Button ("run 2D game", action: {
                    gameManager!.goToScene(.spaceInvaders)
                })
                
                Button ("run AR game", action: {
                    gameManager!.goToScene(.ARGame)
                })
                
            }
            
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        
    }
}

