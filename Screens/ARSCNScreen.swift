//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 16/04/23.
//

import SceneKit
import ARKit
import SwiftUI

struct ARSpaceInvadersViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some ARSpaceInvadersController {
        return ARSpaceInvadersController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class ARSpaceInvadersController: UIViewController {
    var sceneView: ARSCNView!
    var tracking = true
    var trackerNode: SCNNode?
    var planeNode: SCNNode?
    var foundSurface = false
    
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
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        print("setuping scene")
        // Create a new scene
        let scene = SCNScene(named: "ARSpaceInvaders.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
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
        sceneView.scene.rootNode.addChildNode(backBoardNode)
        //        resetGame()
        addNewAlien()
    }
    
    func addNewAlien() {
        let alienNode = ARAlien()
        
        let posX = floatBetween(-0.5, and: 0.5)
        let posY = floatBetween(-0.5, and: 0.5  )
        alienNode.position = SCNVector3(posX, posY, -1) // SceneKit/AR coordinates are in meters
        sceneView.scene.rootNode.addChildNode(alienNode)
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
        
        // Play collision sound for all collisions (bullet-bullet, etc.)
        
//        self.playSoundEffect(ofType: .collision)
//        
//        if explosion {
//            
//            // Play explosion sound for bullet-ship collisions
//            
////            self.playSoundEffect(ofType: .explosion)
//            
//            let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
//            let systemNode = SCNNode()
//            systemNode.addParticleSystem(particleSystem!)
//            // place explosion where node is
//            systemNode.position = node.position
//            sceneView.scene.rootNode.addChildNode(systemNode)
//        }
        
        // remove node
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
        //print("did begin contact", contact.nodeA.physicsBody!.categoryBitMask, contact.nodeB.physicsBody!.categoryBitMask)
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.alien.rawValue || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.alien.rawValue { // this conditional is not required--we've used the bit masks to ensure only one type of collision takes place--will be necessary as soon as more collisions are created/enabled
            
            print("Hit alien!")
            self.removeNodeWithAnimation(contact.nodeB, explosion: false) // remove the bullet
            //                self.userScore += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { // remove/replace ship after half a second to visualize collision
                self.removeNodeWithAnimation(contact.nodeA, explosion: true)
                print("adding new alien because the other was hitted")
                self.addNewAlien()
            })
            
        }
    }
}
