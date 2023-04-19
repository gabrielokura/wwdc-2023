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
    
    var body: some View {
        ZStack () {
            ARSpaceInvadersViewRepresentable()
            if !isPlaying {
                VStack {
                    Text("Kill all the Invaders before they reach you").font(.custom("MachineStd", size: 40))
                    Text("Please orient your device forward").font(.custom("MachineStd", size: 40))
                    Button {
                        manager.startGame()
                        isPlaying = true
                    } label: {
                        Text("PLAY")
                            .frame(width: 100, height: 40, alignment: .center)
                            .foregroundColor(.red)
                            .font(.custom("MachineStd", size: 30))
                    }
                    .padding()
                }
                .frame(alignment: .bottom)
            } else {
                Image("mira")
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .bottom)
                    .foregroundColor(.red)
                    
                if manager.isFirstAlienKilled {
                    ZStack {
                        Rectangle()
                            .fill(.black.opacity(0.1))
                            .frame(width: 500, height: 100)
                        Text("Tap the screen to shoot in the first alien").font(.custom("MachineStd", size: 40))
                            .foregroundColor(.white)
                            
                    }
                    .position(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height - 100)
                }
                
            }
        }
        .frame( maxWidth: .infinity, maxHeight: .infinity)
    }
}
