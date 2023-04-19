//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 13/04/23.
//

import SwiftUI

enum Scenes: String, Identifiable, CaseIterable {
    case menu, spaceInvaders, ARGame, menuAR
    
    var id: String { self.rawValue }
}

class GameManager: ObservableObject {
    // FIXME change this to Scenes.menu
    @Published var selectedScene = Scenes.menu
    
    func goToScene(_ scene: Scenes) {
        selectedScene = scene
    }
}
