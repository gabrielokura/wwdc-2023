//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 19/04/23.
//

import SwiftUI
import SpriteKit

struct EndScreenView: View {
    var body: some View {
        VStack {
            SpriteView(scene: EndScreen.buildScene())
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
}
