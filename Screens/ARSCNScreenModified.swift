////
////  File.swift
////  
////
////  Created by Gabriel Motelevicz Okura on 16/04/23.
////
//
//import SceneKit
//import ARKit
//import SwiftUI
//
//struct ARSpaceInvadersViewRepresentableModified: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> some ARSpaceInvadersController2 {
//        return ARSpaceInvadersController2()
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
//}
//
//class ARSpaceInvadersController2: UIViewController {
//    var sceneView: ARSCNView!
//    var tracking = true
//    var trackerNode: SCNNode?
//    var planeNode: SCNNode?
//    var foundSurface = false
//    var timer: Timer!
//    var alien: ARAlien!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("view loaded")
//        setupScene()
//    }
//    
//    override func loadView() {
//        super.loadView()
//        
//        let sceneView = ARSCNView()
//        self.view = sceneView
//        
//        self.sceneView = sceneView
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        sceneView.session.pause()
//        
//    }
//    
//    func configureSession () {
//        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.horizontal]
//        
//        // Run the view's session
//        sceneView.session.run(configuration)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        // Pause the view's session
//        sceneView.session.pause()
//    }
//    
//    fileprivate func setupScene() {
//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//        
//        print("setuping scene")
//        // Create a new scene
//        let scene = SCNScene(named: "ARSpaceInvaders.scn")!
//        
//        // Set the scene to the view
//        sceneView.scene = scene
//        
//        // loading aliens
//        alien = ARAlien()
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("tocando na tela")
//        if tracking {
//            print("tracking")
//            //Set up the scene
//            guard foundSurface else { return }
//            trackerNode?.removeFromParentNode()
//            print("adding new container")
//            addContainer()
//            sceneView.scene.physicsWorld.contactDelegate = self
//            tracking = false
//            print("tracking \(tracking)")
//            
//        } else {
//            print("firing")
//            fire()
//        }
//    }
//    
//    func addInitialAlien() {
//        //Add initial target after 1.5
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//            self.addNewAlien()
//        })
//    }
//    
//    func addContainer() {
//        guard let backboardScene = SCNScene(named: "ARSpaceInvaders.scn") else {
//            return
//        }
//        guard let backBoardNode = backboardScene.rootNode.childNode(withName: "container", recursively: true) else {
//            return
//        }
//        backBoardNode.isHidden = false
//        sceneView.scene.rootNode.addChildNode(backBoardNode)
//        //        resetGame()
//        addInitialAlien()
//    }
//    
//    func addNewAlien() {
//        print("placing one more Alien")
//        let alienCopy = alien.clone()
//        //        let alienCopy = ARAlien()
//        
//        let posX = floatBetween(-0.5, and: 0.5)
//        let posY = Float(0)
//        alienCopy.position = SCNVector3(posX, posY, -2)
//        sceneView.scene.rootNode.addChildNode(alienCopy)
//        
//        self.directNodeTowardCamera(alienCopy)
//    }
//    
//    func directNodeTowardCamera(_ node: SCNNode) {
//        node.physicsBody?.clearAllForces()
//        //Make cube node go towards camera
//        let (_, playerPosition) = self.getCameraVector()
//        let impulseVector = SCNVector3(
//            x: self.randomOneOfTwoInputFloats(-0.50, and: 0.50),
//            y: playerPosition.y,
//            z: playerPosition.z
//        )
//        
//        //Makes generated nodes rotate when applied with force
//        let positionOnNodeToApplyForceTo = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
//        
//        node.physicsBody?.applyForce(impulseVector, at: positionOnNodeToApplyForceTo, asImpulse: true)
//    }
//    
//    func removeNodeWithAnimation(_ node: SCNNode, explosion: Bool) {
//        // remove node
//        print("removing \(node.name ?? "nil")")
//        node.removeFromParentNode()
//        
//    }
//    
//    func addPlayer() {
//        let playerNode = ARPlayer()
//        playerNode.position = self.getCameraPosition()
//        sceneView.scene.rootNode.addChildNode(playerNode)
//        self.planeNode = playerNode
//    }
//    
//    func fire() {
//        let bulletsNode = Bullet()
//        
//        let (direction, position) = self.getUserVector()
//        bulletsNode.position = position // SceneKit/AR coordinates are in meters
//        
//        let bulletDirection = direction
//        bulletsNode.physicsBody?.applyForce(bulletDirection, asImpulse: true)
//        sceneView.scene.rootNode.addChildNode(bulletsNode)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { // remove/replace ship after half a second to visualize collision
//            self.removeNodeWithAnimation(bulletsNode, explosion: false)
//        })
//    }
//    
//    
//}
//
//extension ARSpaceInvadersController {
//    
//    func getTargetVector(for alien: ARAlien?) -> (SCNVector3, SCNVector3) { // (direction, position)
//        guard let alien = alien else {return (SCNVector3Zero, SCNVector3Zero)}
//        
//        let mat = alien.presentation.transform // 4x4 transform matrix describing target node in world space
//        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of target node in world space
//        let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of target node world space
//        return (dir, pos)
//    }
//    
//    func getCameraVector() -> (SCNVector3, SCNVector3)  { // (direction, position)
//        
//        if let frame = self.sceneView.session.currentFrame {
//            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
//            let dir = SCNVector3(mat.m31, mat.m32, mat.m33) // orientation of camera in world space
//            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
//            
//            return (dir, pos)
//        }
//        return (SCNVector3Zero, SCNVector3Zero)
//    }
//    
//    func getCameraPosition() -> SCNVector3 {
//        let (_ , position) = self.getCameraVector()
//        return position
//    }
//    
//    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
//        if let frame = self.sceneView.session.currentFrame {
//            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
//            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
//            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
//            
//            return (dir, pos)
//        }
//        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
//    }
//    
//    func floatBetween(_ first: Float,  and second: Float) -> Float { // random float between upper and lower bound (inclusive)
//        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
//    }
//    
//    
//    func randomOneOfTwoInputFloats(_ first: Float, and second: Float) -> Float {
//        let array = [first, second]
//        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
//        
//        return array[randomIndex]
//    }
//}
//
//
//extension ARSpaceInvadersController: ARSessionDelegate {
//    
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        self.planeNode?.position = self.getCameraPosition()
//        // display direction setas
//    }
//}
//
//extension ARSpaceInvadersController: SCNPhysicsContactDelegate {
//    
//    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue && contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.bullet.rawValue) ||
//            (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.bullet.rawValue && contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue){
//            //target was hit from bullet!
//            print("Hit target!")
//            
//            self.removeNodeWithAnimation(contact.nodeB, explosion: false)
//            self.removeNodeWithAnimation(contact.nodeA, explosion: false)
//            //                self.userScore += 1
//            
//            self.addNewAlien()
//        }else if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue &&
//                  contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.player.rawValue) ||
//                    (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.player.rawValue &&
//                     contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue){
//            //Player was hit by target!
//            print("Player Dead!")
//            
//            self.removeNodeWithAnimation(contact.nodeB, explosion: false)
//            self.removeNodeWithAnimation(contact.nodeA, explosion: false)
//            
//            //                self.endPlaying()
//        }
//    }
//}
