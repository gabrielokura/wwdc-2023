//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 15/04/23.
//

import RealityKit
import Combine

//class ARModel {
//    var modelName: String
//    var modelEntity: Entity?
//    
//    private var cancellable: AnyCancellable? = nil
//    
//    var aliens = [ARAlien]()
//    
//    init(modelName: String) {
//        self.modelName = modelName
//        
//        self.cancellable = Entity.loadAsync(named: modelName).sink(receiveCompletion: { loadCompletion in
//            // Handle out error
//            print("[DEBUG] finish load: \(modelName)")
//        }, receiveValue: { modelEntity in
//            // Get our model entity
//            self.modelEntity = modelEntity
//            print("[DEBUG] Successfully loaded model entity: \(modelName)")
//            print("[DEBUG] primeiro elemento tem \(modelEntity.children.first?.children) filhos")
//            
//            for alienEntity in modelEntity.children.first!.children {
//                print("[DEBUG] creating \(alienEntity.name)")
//                self.aliens.append(ARAlien(alienEntity))
//            }
//        })
//    }
//}
