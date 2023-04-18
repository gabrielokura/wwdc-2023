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
    
    @Published var canPlaceObject = false
    @Published var isPlaced = false
    
    func canPlace(_ canPlace: Bool) {
        canPlaceObject = canPlace
    }
    
    func placeObject() {
        isPlaced = true
    }
}
