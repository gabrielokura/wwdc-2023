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
    @StateObject var manager = ARManager()
    
    var body: some View {
        ZStack (alignment: .bottom) {
            ARSpaceInvadersViewRepresentable(gameManger: manager)
            if !manager.isPlaying {
                VStack {
                    Text("Kill all the Invaders before they reach you").font(.custom("MachineStd", size: 40))
                    Button {
                        manager.actionStream.send(.start)
                    } label: {
                        Text("START")
                            .frame(width: 100, height: 40, alignment: .center)
                            .foregroundColor(.red)
                            .font(.custom("MachineStd", size: 30))
                    }
                    .padding()
                    .frame(alignment: .bottom)
                }
            } else {
                Text("Tao the screen to shoot").font(.custom("MachineStd", size: 40))
            }
        }
    }
}
