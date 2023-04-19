//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 13/04/23.
//

import SwiftUI
import Combine

enum Scenes: String, Identifiable, CaseIterable {
    case menu, spaceInvaders, ARGame, menuAR, end
    
    var id: String { self.rawValue }
}

class GameManager: ObservableObject {
    // FIXME change this to Scenes.menu
    @Published var selectedScene = Scenes.menu
    
    func goToScene(_ scene: Scenes) {
        selectedScene = scene
    }
}


class ARManager: ObservableObject {
    init() {}
    
    static var shared = ARManager()
    
    var actionStream = PassthroughSubject<ARAction, Never>()
    
    @Published var isPlaying = false
    @Published var hintText = ""
    @Published var isFirstAlienKilled = false
    
    func startGame() {
        isPlaying = true
        actionStream.send(.start)
    }
    
    func updateText(_ text: String) {
        hintText = text
    }
}
