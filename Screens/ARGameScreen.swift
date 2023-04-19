//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 18/04/23.
//

import SceneKit
import ARKit
import SwiftUI

struct ARSpaceInvadersViewRepresentable: UIViewControllerRepresentable {
    var gameManger: ARManager!
    
    init(gameManger: ARManager!) {
        self.gameManger = gameManger
    }
    
    func makeUIViewController(context: Context) -> some ARSpaceInvadersController {
        let controller = ARSpaceInvadersController()
        controller.gameManager = gameManger
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class ARSpaceInvadersController: UIViewController {
    var sceneView: ARSCNView!
    var tracking = true
    var trackerNode: SCNNode?
    var planeNode: SCNNode?
    var foundSurface = false
    var alien: ARAlien!
    var player: ARPlayer!
    
    var gameManager: ARManager?
    
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
        sceneView.delegate = self
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
    }
    
    var strength = CGFloat(10)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if tracking {
            //Set up the scene
            guard foundSurface else { return }
            trackerNode?.removeFromParentNode()
            print("adding new container")
            addContainer()
            sceneView.scene.physicsWorld.contactDelegate = self
            tracking = false
        } else {
            fire()
        }
    }
    
    func addContainer() {
        guard let backboardScene = SCNScene(named: "ARSpaceInvaders.scn") else {
            return
        }
        guard let backBoardNode = backboardScene.rootNode.childNode(withName: "container", recursively: true) else {
            return
        }
        backBoardNode.isHidden = false
//        sceneView.scene.rootNode.addChildNode(backBoardNode)
        //        resetGame()
        addPlayer()
        addNewAlien()
        
    }
    
    func addNewAlien() {
//        let alienNode = alien.node.clone()
        let alienNode = ARAlien().node!
        
        print("alien node category \(alienNode.physicsBody?.categoryBitMask ?? 99)")
        
//        let posX = floatBetween(-0.5, and: 0.5)
        let posX = Float(0)
//        let posY = floatBetween(-0.5, and: 0.5)
        let posY = Float(0)
        alienNode.position = SCNVector3(posX, posY, -2) // SceneKit/AR coordinates are in meters
        sceneView.scene.rootNode.addChildNode(alienNode)
        
//        self.directNodeTowardCamera(alienNode)
    }
    
    func addPlayer() {
        let playerNode = ARPlayer()
//        playerNode.position = self.getCameraPosition()
        sceneView.scene.rootNode.addChildNode(playerNode)
        self.player = playerNode
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
    
    func removeNodeWithAnimation(_ node: SCNNode, explosion: Bool) {
        // remove node
        node.physicsBody = nil
        node.removeFromParentNode()
    }
    
    func fire() {
        let bulletsNode = Bullet()
        
        let (direction, position) = self.getUserVector()
        bulletsNode.position = position // SceneKit/AR coordinates are in meters
        
        let bulletDirection = direction
        bulletsNode.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletsNode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { // remove/replace ship after half a second to visualize collision
            self.removeNodeWithAnimation(bulletsNode, explosion: false)
        })
    }
    
    
}


extension ARSpaceInvadersController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            guard self.tracking else { return }
            //            let hitTest = self.sceneView.hitTest(CGPoint(x: self.view.frame.midX, y: self.view.frame.midY), types: .featurePoint)
            guard let hitTest = self.sceneView.raycastQuery(from: CGPoint(x: self.view.frame.midX, y: self.view.frame.midY), allowing: .existingPlaneInfinite, alignment: .horizontal) else { return }
            
            let results = self.sceneView.session.raycast(hitTest)
            guard let hitTestResult = results.first else { return }
            let translation = SCNMatrix4(hitTestResult.worldTransform)
            let position = SCNVector3Make(translation.m41, translation.m42, translation.m43)
            if self.trackerNode == nil { //1
                let plane = SCNPlane(width: 0.15, height: 0.15)
                plane.firstMaterial?.diffuse.contents = UIImage(named: "tracker.png")
                plane.firstMaterial?.isDoubleSided = true
                self.trackerNode = SCNNode(geometry: plane) //2
                self.trackerNode?.eulerAngles.x = -.pi * 0.5 //3
                self.sceneView.scene.rootNode.addChildNode(self.trackerNode!)
                self.foundSurface = true //4
            }
            self.trackerNode?.position = position //5
        }
    }
    
}//
extension ARSpaceInvadersController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue && contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.bullet.rawValue) ||
            (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.bullet.rawValue && contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue){
            //target was hit from bullet!
            print("Hit target!")
            
            self.removeNodeWithAnimation(contact.nodeB, explosion: false)
            self.removeNodeWithAnimation(contact.nodeA, explosion: false)
            //                self.userScore += 1
            
            self.addNewAlien()
        }else if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue &&
                  contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.player.rawValue) ||
                    (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.player.rawValue &&
                     contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue){
            //Player was hit by target!
            print("Player Dead!")
            
//            self.removeNodeWithAnimation(contact.nodeB, explosion: false)
//            self.removeNodeWithAnimation(contact.nodeA, explosion: false)
            
            //                self.endPlaying()
        }
    }
}

extension ARSpaceInvadersController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.player?.position = self.getCameraPosition()
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
}
