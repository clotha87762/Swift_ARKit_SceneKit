//
//  ViewController.swift
//  qaq
//
//  Created by user on 2017/11/13.
//  Copyright © 2017年 mhci. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import QuartzCore


struct CollisionCategory :OptionSet{
    let rawValue :Int
    
    static let CollisionCategoryBox = CollisionCategory(rawValue: 1<<0)
    
    static let CollisionCategoryPlane = CollisionCategory(rawValue: 1<<1)
    
}

class ARPlane : SCNNode {
    var planeAnchor : ARPlaneAnchor!
    var planeGeometry : SCNPlane!
    var selfNode : SCNNode!
    
    public convenience init(_ anchor : ARPlaneAnchor){
        self.init()
        planeAnchor = anchor
        planeGeometry = SCNPlane( width: CGFloat(anchor.extent.x * 4.0) , height: CGFloat(anchor.extent.z * 4.0))
        //planeGeometry = SCNBox(width: CGFloat(anchor.extent.x * 10), height: CGFloat(0.3), length: CGFloat(anchor.extent.z * 10), chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage( named: "art.scnassets/character/max_diffuse.png")
       // planeGeometry.materials = [material, material, material, material, material, material]
        planeGeometry.materials = [material]
        
        selfNode = SCNNode(geometry: planeGeometry)
        selfNode.position = SCNVector3Make(0,0,0)
        
        selfNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        //setTextureScale()
        
        //let shape = SCNPhysicsShape(geometry: planeGeometry, options: nil)
        
        selfNode.physicsBody = SCNPhysicsBody(type: .kinematic ,shape: nil) // is shape really nillllll????
        selfNode.physicsBody?.isAffectedByGravity = false;
         selfNode.physicsBody?.rollingFriction = 0.3
        //selfNode.physicsBody?.friction = 1.0
        
        
        
        //planeNode.physicsBody = SCNPhysicsBody(type: .static ,shape:nil) // is shape really nillllll????
        selfNode.physicsBody?.categoryBitMask = CollisionCategory.CollisionCategoryPlane.rawValue
        selfNode.physicsBody?.collisionBitMask = CollisionCategory.CollisionCategoryBox.rawValue
        selfNode.physicsBody?.contactTestBitMask = CollisionCategory.CollisionCategoryBox.rawValue
        
        self.name = "plane"
        
        
        addChildNode(selfNode)
        
        
    }
    
    func update(_ anchor : ARPlaneAnchor){
        
        
        //planeGeometry.width = CGFloat(anchor.extent.x * 30  )
        //planeGeometry.height = CGFloat(anchor.extent.z * 30)
        position = SCNVector3Make(anchor.center.x, 0 , anchor.center.z )
        
        planeGeometry = SCNPlane( width: CGFloat(anchor.extent.x * 4.0) , height: CGFloat(anchor.extent.z * 4.0))
        //planeGeometry = SCNBox(width: CGFloat(anchor.extent.x * 10), height: CGFloat(0.3), length: CGFloat(anchor.extent.z * 10), chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage( named: "art.scnassets/character/max_diffuse.png")
        planeGeometry.materials = [material]
        //planeGeometry.materials = [material, material, material, material, material, material]
        
        
        
        selfNode.removeFromParentNode()
        
        
        selfNode = SCNNode(geometry: planeGeometry)
        selfNode.position = SCNVector3Make(0,0,0)
        
        selfNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        setTextureScale()
        
        //let shape = SCNPhysicsShape(geometry: planeGeometry, options: nil)
        
        selfNode.physicsBody = SCNPhysicsBody(type: .kinematic ,shape: nil) // is shape really nillllll????
        selfNode.physicsBody?.isAffectedByGravity = false;
        selfNode.physicsBody?.rollingFriction = 0.5
        selfNode.physicsBody?.friction = 0.8
        
        //planeNode.physicsBody = SCNPhysicsBody(type: .static ,shape:nil) // is shape really nillllll????
        selfNode.physicsBody?.categoryBitMask = CollisionCategory.CollisionCategoryPlane.rawValue
        selfNode.physicsBody?.collisionBitMask = CollisionCategory.CollisionCategoryBox.rawValue
        selfNode.physicsBody?.contactTestBitMask = CollisionCategory.CollisionCategoryBox.rawValue
        
        addChildNode(selfNode)
        
        //setTextureScale()
 
    }
    
    func setTextureScale(){
        let width = planeGeometry.width
        let height = planeGeometry.height
        let material = planeGeometry.firstMaterial
        
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale( Float(width), Float(height), 1)
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
        
    }
    
    
}

class ViewController: UIViewController, ARSCNViewDelegate ,ARSessionDelegate ,SCNPhysicsContactDelegate{

    @IBOutlet var sceneView: ARSCNView!
    
    var planes = [NSString:ARPlane]()
    var foxes :[SCNNode] = []
    var cameraNode = SCNNode()
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = ARPlane(planeAnchor)
            node.addChildNode(plane)
            planes[ NSString(string: anchor.identifier.uuidString) ] = plane
            
        }
        else{
            return
        }
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let plane = planes[NSString(string: anchor.identifier.uuidString)] as? ARPlane{
            
            let planeAnchor = anchor as! ARPlaneAnchor
            plane.update(planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
 
    
    func sceneSpacePosition(inFrontOf node: SCNNode, atDistance distance: Float) -> SCNVector3 {
        let localPosition = SCNVector3(x: 0, y: 0, z: Float(-distance))
        let scenePosition = node.convertPosition(localPosition, to: nil)
        // to: nil is automatically scene space
        return scenePosition
    }
    
   
    @objc
    func handleARSwipe(_ gestureRecognize:UIGestureRecognizer){
        
    
        print("qq")
        
        //var qq = gestureRecognize as! UIPanGestureRecognizer
        //print("velocity \(qq.velocity(in: sceneView)))" )
        
        //let scene = SCNScene(named: "art.scnassets/character/max.scn")!
        //let fox = scene.rootNode.childNode(withName:"Max_rootNode",recursively: true)!
        let scene = SCNScene(named: "art.scnassets/character/max.scn")!
        let fox = scene.rootNode.childNode(withName: "Max_rootNode", recursively: true)!
        let collider = fox.childNode(withName: "collider", recursively: true)!
        let max = fox.childNode(withName: "Max" , recursively: true)!
        let bip = fox.childNode(withName: "Bip001" , recursively: true)!
        
        //fox.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        /*
        let sphere = SCNSphere ( radius: 0.05)
        
        collider.physicsBody?.physicsShape = SCNPhysicsShape(geometry: sphere, options: nil)
        
        collider.physicsBody?.categoryBitMask = CollisionCategory.CollisionCategoryBox.rawValue
        collider.physicsBody?.collisionBitMask = CollisionCategory.CollisionCategoryBox.rawValue
        collider.physicsBody?.contactTestBitMask = CollisionCategory.CollisionCategoryBox.rawValue
        
        collider.physicsBody?.damping = 0
      
        let (direction, pos) = self.getUserVector()
        fox.position = pos
        let throwdirection = SCNVector3Make( direction.x * 10 , direction.y * 10, direction.z * 10)
        
        collider.physicsBody?.isAffectedByGravity = true;
        collider.physicsBody?.applyForce( throwdirection, asImpulse: true)
        //collider.physicsBody?.applyForce(throwdirection, asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(fox)
        
        print(fox.position)
        
        */
        
        let node = SCNNode()
        
        max.name = "fox"
        bip.name = "fox"
        node.addChildNode(max)
        node.addChildNode(bip)
        node.transform = fox.transform
        
        let sphere = SCNSphere ( radius: 0.025)
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        node.physicsBody?.mass = 0.5
        node.physicsBody?.rollingFriction = 0.3
        node.physicsBody?.friction = 1.0
        
        
       
        node.physicsBody?.categoryBitMask = CollisionCategory.CollisionCategoryBox.rawValue
        node.physicsBody?.contactTestBitMask = CollisionCategory.CollisionCategoryBox.rawValue | CollisionCategory.CollisionCategoryPlane.rawValue
        node.physicsBody?.collisionBitMask = CollisionCategory.CollisionCategoryBox.rawValue | CollisionCategory.CollisionCategoryPlane.rawValue
        
        
        //let material = SCNMaterial()
        //material.diffuse.contents = UIImage(named: "art.scnassets/texture.png")
        //node.geometry?.materials  = [material, material, material, material, material, material]
        
        let (direction, pos) = self.getUserVector()
        node.position = pos
        let throwdirection = SCNVector3Make( direction.x * 5 , direction.y * 5, direction.z * 5)
        node.physicsBody?.applyForce( throwdirection, asImpulse: true)
        
        print(throwdirection)
        node.name = "fox"
        
        
 

        
       
        /*
         let walkAnimation = Character.loadAnimation(fromSceneNamed: "Art.scnassets/character/max_walk.scn")
         walkAnimation.speed = Character.speedFactor
         walkAnimation.stop()
         
         if Character.enableFootStepSound {
         walkAnimation.animation.animationEvents = [
         SCNAnimationEvent(keyTime: 0.1, block: { _, _, _ in self.playFootStep() }),
         SCNAnimationEvent(keyTime: 0.6, block: { _, _, _ in self.playFootStep() })
         ]
         }
         model.addAnimationPlayer(walkAnimation, forKey: "walk")
         */
        
        let jumpAnimation = loadAnimation(fromSceneNamed: "art.scnassets/character/max_jump.scn")
        jumpAnimation.animation.isRemovedOnCompletion = false
        jumpAnimation.stop()
        jumpAnimation.animation.animationEvents = [SCNAnimationEvent(keyTime: 0, block: { _, _, _ in self.playJumpSound() })]
        node.addAnimationPlayer(jumpAnimation, forKey: "jump")
        
        
        let idleAnimation = loadAnimation(fromSceneNamed: "art.scnassets/character/max_idle.scn")
        node.addAnimationPlayer(idleAnimation, forKey: "idle")
        node.animationPlayer(forKey: "idle")?.play()
    
        /*
         let spinAnimation = Character.loadAnimation(fromSceneNamed: "Art.scnassets/character/max_spin.scn")
         spinAnimation.animation.isRemovedOnCompletion = false
         spinAnimation.speed = 1.5
         spinAnimation.stop()
         spinAnimation.animation.animationEvents = [SCNAnimationEvent(keyTime: 0, block: { _, _, _ in self.playAttackSound() })]
         model!.addAnimationPlayer(spinAnimation, forKey: "spin")
         */
 
         foxes.append(fox)
         sceneView.scene.rootNode.addChildNode(node)
        
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        
        print("qaq")
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    func playJumpSound(){
        
    }
    
    func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: sceneName )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                  ARSCNDebugOptions.showWorldOrigin]
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let ship = scene.rootNode.childNode(withName: ("ship"), recursively: true)
        ship?.scale = SCNVector3Make(0,0,0)
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.delegate = self
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        let swipeGesture = UISwipeGestureRecognizer(target:self,action: #selector(handleARSwipe(_:)))
        swipeGesture.numberOfTouchesRequired = 1
        swipeGesture.direction = .up
        sceneView.addGestureRecognizer(swipeGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        tapGesture.require(toFail:swipeGesture)
        sceneView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        print("QAQ")
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults.first
            print("something (\result?.node.name)")
            if result?.node.name == "fox" {
                
                let node = result?.node.parent
                node?.physicsBody?.applyForce( SCNVector3Make(0, 1 , 0), asImpulse: true)
                
                node?.animationPlayer(forKey: "idle")?.stop()
                node?.animationPlayer(forKey: "jump")?.play()
                
                
            }
            
      
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //print("did begin contact", contact.nodeA.physicsBody!.categoryBitMask, contact.nodeB.physicsBody!.categoryBitMask)
        if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.CollisionCategoryBox.rawValue) &&
            (contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.CollisionCategoryPlane.rawValue) {
            
            print("A")
             contact.nodeA.animationPlayer(forKey: "jump")?.stop()
            contact.nodeA.animationPlayer(forKey: "idle")?.play()
            
        }
        else if(contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.CollisionCategoryBox.rawValue) &&
            (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.CollisionCategoryPlane.rawValue){
            print("B")
            contact.nodeB.animationPlayer(forKey: "jump")?.stop()
            contact.nodeB.animationPlayer(forKey: "idle")?.play()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
}
