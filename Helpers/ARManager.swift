//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 07/04/23.
//

import Combine

class ARManager: ObservableObject {
    init() {}
    
    var actionStream = PassthroughSubject<ARAction, Never>()
    
    @Published var isPlaying = false
    
    
    func startGame() {
        isPlaying = true
    }
}
