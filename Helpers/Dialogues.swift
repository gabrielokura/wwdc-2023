//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 17/04/23.
//

import SpriteKit

enum DialoguesPhase {
    case text1, text2, text3, text4, text5, learningAccelerometer, learningShoot
}

class Dialogues {
    var dialogueNodes = [SKSpriteNode]()
    var phase: DialoguesPhase = .text1
    var index = 0
    var hintText: SKLabelNode!
    
    var passSound = SKAction.playSoundFileNamed("dialogue_sound.wav", waitForCompletion: false)
    
    var isShowing: Bool {
        get {
            return index < dialogueNodes.count
        }
    }
    
    init(_ scene: SKScene, _ hintText: SKLabelNode) {
        let parentNode = scene.childNode(withName: "dialogues")
        self.hintText = hintText
        
        for node in parentNode!.children {
            node.isHidden = true
            self.dialogueNodes.append(node as! SKSpriteNode)
        }
        
        startTutorial()
    }
    
    
    func startTutorial() {
        print("children: \(dialogueNodes.count)")
        dialogueNodes.first?.isHidden = false
    }
    
    func nextDialogue(_ muteSound: Bool) {
        print("current dialogue \(dialogueNodes[index].name!)")
        dialogueNodes[index].isHidden = true
        
        if !muteSound {
            dialogueNodes[index].run(passSound)
        }
        
        index += 1
        
        switch index {
        case 1:
            phase = .text2
        case 2:
            phase = .text3
        case 3:
            phase = .text4
        case 4:
            phase = .text5
        case 5:
            phase = .learningAccelerometer
            hintText.text = "Move your iPad"
        case 6:
            phase = .learningShoot
            hintText.text = "Now is your turn"
        default:
            phase = .text1
        }
        
        if index == 7 {
            hintText.removeFromParent()
        }
        
        if index >= dialogueNodes.count {
            return
        }
        
        dialogueNodes[index].isHidden = false
        print("next dialogue \(dialogueNodes[index].name!)")
        
        
        
    }
    
}
