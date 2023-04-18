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
            ARSpaceInvadersViewRepresentable()
            
//            if manager.isPlaced {
//                Text("Tap in yout screen to shot on aliens")
//            } else {
//                switch manager.canPlaceObject {
//                case true:
//                    Button {
//                        manager.actionStream.send(.start)
//                    } label: {
//                        Text("START")
//                            .frame(width: 100, height: 40, alignment: .center)
//                            .foregroundColor(.red)
//                    }
//                    .padding()
//                    .frame(alignment: .bottom)
//                case false:
//                    Text("Please find a horizontal plane to start the game")
//                        .frame(alignment: .center)
//                }
//            }
        }
        
        
    }
}
