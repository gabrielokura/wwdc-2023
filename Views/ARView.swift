//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 07/04/23.
//

import RealityKit
import SwiftUI
import ARKit
import Combine

struct MyARView: View {
    @StateObject var manager = ARManager.shared
    @State var isPlaying = false
    @State var score = 0
    
    var body: some View {
        ZStack () {
            ARSpaceInvadersViewRepresentable()
            if !isPlaying {
                VStack {
                    Text("Please orient your device forward").font(.custom("MachineStd", size: 40))
                        .shadow( color: .black, radius: 1)
                    Text("Kill all the Invaders before they reach you").font(.custom("MachineStd", size: 40))
                        .shadow( color: .black, radius: 1)
                    Button {
                        manager.startGame()
                        isPlaying = true
                    } label: {
                        Text("PLAY")
                            .frame(width: 150, height: 80, alignment: .center)
                            .foregroundColor(.red)
                            .font(.custom("MachineStd", size: 40))
                            .shadow(color: .black, radius: 1)
                    }
                    .padding()
                }
                .frame(alignment: .bottom)
            } else {
                Image("mira")
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .bottom)
                    .foregroundColor(.red)
                
                Text("Score: \(manager.score)").font(.custom("MachineStd", size: 40))
                    .position(x: UIScreen.main.bounds.size.width - 100, y: 100)
                    .shadow( color: .black, radius: 1)
                    
                if !manager.isFirstAlienKilled {
                    Text("Tap the screen to shoot in the first alien").font(.custom("MachineStd", size: 40))
                        .position(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height - 100)
                        .foregroundColor(.white)
                        .shadow( color: .black, radius: 1)
                }
                
            }
        }
        .frame( maxWidth: .infinity, maxHeight: .infinity)
    }
}
