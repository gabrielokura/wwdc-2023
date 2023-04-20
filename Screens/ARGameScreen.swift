//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 18/04/23.
//

import SceneKit
import ARKit
import SwiftUI
import Combine

struct ARSpaceInvadersViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some ARSpaceInvadersController {
        let controller = ARSpaceInvadersController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

class ARSpaceInvadersController: UIViewController {
    var sceneView: ARSCNView!
    var planeNode: SCNNode?
    var alien: ARAlien!
    var player: ARPlayer!
    var isPlaying = false
    var score = 0
    
    var firstKill = true
    
    var charge: CGFloat = -1
    var arManager: ARManager = ARManager.shared
    
    var tapSound = SCNAudioSource(fileNamed: "tap_arcade_sound.wav")
    var fireSound = SCNAudioSource(fileNamed: "ar_fire_sound.m4a")
    var explosionSound = SCNAudioSource(fileNamed: "arcade_explosion_sound.wav")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    override func loadView() {
        super.loadView()
        
        let sceneView = ARSCNView()
        self.view = sceneView
        
        self.sceneView = sceneView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    fileprivate func setupScene() {
        // Set the view's delegate
//        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        print("setuping scene")
        // Create a new scene
        let scene = SCNScene(named: "ARSpaceInvaders.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // load alien model and
        alien = ARAlien()
        
        // subscribe to manager actions
        subscribeToActions()
    }
    
    var strength = CGFloat(10)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isPlaying {
            return
        }
        
        fire()
    }
    
    func addContainer() {
        guard let backboardScene = SCNScene(named: "ARSpaceInvaders.scn") else {
            return
        }
        guard let backBoardNode = backboardScene.rootNode.childNode(withName: "container", recursively: true) else {
            return
        }
        backBoardNode.isHidden = false
        addPlayer()
        addInitialAlien()
    }
    
    func startGame() {
        isPlaying = true
        addContainer()
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    private var cancellable = Set<AnyCancellable>()
    
    func subscribeToActions() {
        print("subscribing...")
        
        arManager.actionStream.sink { action in
            print("action \(action)")
            self.startGame()
        }
        .store(in: &cancellable)
    }
    
    func addInitialAlien() {
        let alienNode = ARAlien().node!
        
        print("First alien")
        
        let posX = Float(0)
        let posY = getCameraPosition().y - 0.1
        alienNode.position = SCNVector3(posX, posY, -2)
        alienNode.physicsBody?.charge = 0
        sceneView.scene.rootNode.addChildNode(alienNode)
        
    }
    
    func addNewAlien() {
        let alienNode = ARAlien().node!
        
        print("alien node category \(alienNode.physicsBody?.categoryBitMask ?? 99)")
        
        let posX = getCameraPosition().x + floatBetween(-2, and: 2)
        let posY = getCameraPosition().y - 0.1
        alienNode.position = SCNVector3(posX, posY, -4)
        alienNode.physicsBody?.charge = charge// SceneKit/AR coordinates are in meters
        sceneView.scene.rootNode.addChildNode(alienNode)
        
        charge -= 0.1
    }
    
    func addPlayer() {
        let playerNode = ARPlayer()
        playerNode.position = self.getCameraPosition()
        sceneView.scene.rootNode.addChildNode(playerNode)
        self.player = playerNode
    }
        
    
    
    func removeNodeWithAnimation(_ node: SCNNode, explosion: Bool) {
        // remove node
        node.physicsBody = nil
        node.removeFromParentNode()
    }
    
    func fire() {
        let bulletsNode = Bullet()
        
        let (direction, position) = self.getUserVector()
        bulletsNode.position = position // SceneKit/AR coordinates are in meters
        
        let bulletDirection = SCNVector3(x: direction.x * 2, y: direction.y * 2, z: direction.z * 2)
        bulletsNode.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletsNode)
        
        if fireSound != nil {
            self.player.runAction(SCNAction.playAudio(fireSound!, waitForCompletion: false))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { // remove/replace ship after half a second to visualize collision
            self.removeNodeWithAnimation(bulletsNode, explosion: false)
        })
    }

    func setFirstKill() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.1)) {
            self.arManager.isFirstAlienKilled = true
        }
        firstKill = false
    }
    
    
}

extension ARSpaceInvadersController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue && contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.bullet.rawValue) ||
            (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.bullet.rawValue && contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue){
            //target was hit from bullet!
            print("Hit target!")
            
            if explosionSound != nil {
                self.sceneView.scene.rootNode.runAction(SCNAction.playAudio(explosionSound!, waitForCompletion: false))
            }
            
            self.removeNodeWithAnimation(contact.nodeB, explosion: false)
            self.removeNodeWithAnimation(contact.nodeA, explosion: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.1)) {
                self.arManager.sumScore(10)
            }
            
            if firstKill {
                setFirstKill()
            }
            
            self.addNewAlien()
        }else if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue &&
                  contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.player.rawValue) ||
                    (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.player.rawValue &&
                     contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue){
            //Player was hit by target!
            print("Player Dead!")
            
            if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue {
                self.removeNodeWithAnimation(contact.nodeA, explosion: false)
                addNewAlien()
            } else {
                self.removeNodeWithAnimation(contact.nodeB, explosion: false)
                addNewAlien()
            }
        }
    }
}

extension ARSpaceInvadersController: ARSessionDelegate, ARSCNViewDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.player?.position = self.getCameraPosition()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if score > 20 {
            print("END GAME")
        }
    }
}

extension ARSpaceInvadersController {
    func getCameraVector() -> (SCNVector3, SCNVector3)  { // (direction, position)
        
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(mat.m31, mat.m32, mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3Zero, SCNVector3Zero)
    }
    
    func getCameraPosition() -> SCNVector3 {
        let (_ , position) = self.getCameraVector()
        return position
    }
    
    func directNodeTowardCamera(_ node: SCNNode) {
        node.physicsBody?.clearAllForces()
        //Make cube node go towards camera
        let (_, playerPosition) = self.getCameraVector()
        let impulseVector = SCNVector3(
            x: self.randomOneOfTwoInputFloats(-0.50, and: 0.50),
            y: playerPosition.y,
            z: playerPosition.z
        )
        
        //Makes generated nodes rotate when applied with force
        let positionOnNodeToApplyForceTo = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
        
        node.physicsBody?.applyForce(impulseVector, at: positionOnNodeToApplyForceTo, asImpulse: true)
    }
    
    
    func randomOneOfTwoInputFloats(_ first: Float, and second: Float) -> Float {
        let array = [first, second]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        
        return array[randomIndex]
    }
    
    func floatBetween(_ first: Float,  and second: Float) -> Float { // random float between upper and lower bound (inclusive)
        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
}
