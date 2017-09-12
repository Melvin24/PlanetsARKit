//
//  ViewController.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 04/09/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var configuration: ARWorldTrackingConfiguration!
    
    // A dictionary of all the current planes being rendered in the scene
    var planes: [UUID : Plane] = [:]
    
    // Contains a list of all the boxes rendered in the scene
    var boxes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView(using: sceneView)
        setupTapGestureRecogniser(for: sceneView)
    
        // Stop the screen from dimming while we are using the app
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    func setupTapGestureRecogniser(for sceneView: ARSCNView) {
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        sceneView.addGestureRecognizer(tapGestureRec)
    }
    
    func setupView(using sceneView: ARSCNView) {
        sceneView.delegate = self

        // Make things look pretty
        sceneView.antialiasingMode = .multisampling4X
        
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let baseScene = SCNScene()
        sceneView.scene = baseScene
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        
        let hitResult = sceneView.hitTest(tapPoint, types: [.existingPlaneUsingExtent])
        guard hitResult.count > 0 else {
            return
        }
        
        // If there are multiple hits, just pick the closest plane
        let closestHitResult = hitResult[0]
        
        let node = nodeAt(hitResult: closestHitResult)
        
        sceneView.scene.rootNode.addChildNode(node)
        
        boxes.append(node)
        
    }
    
    func nodeAt(hitResult: ARHitTestResult) -> SCNNode {
        
        let aBox = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let node = SCNNode(geometry: aBox)
        
        // The physicsBody tells SceneKit this geometry should be
        // manipulated by the physics engine
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        node.physicsBody?.mass = 2.0
        
        node.physicsBody?.categoryBitMask = Int(SCNPhysicsCollisionCategory.default.rawValue)
        
        // We insert the geometry slightly above the point the user tapped
        // so that it drops onto the plane using the physics engine
        node.position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + 0.3,
            hitResult.worldTransform.columns.3.z
        )
        
        return node
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        // Create a session configuration
        configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        // Run the view's session
        /// Run Session on start
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        return SCNNode()
    }

    /// Tells the delegate that a SceneKit node corresponding to a new AR anchor has been added to the scene.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeARAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = Plane(withAnchor: planeARAnchor, hidden: false)
        self.planes[planeARAnchor.identifier] = plane
        node.addChildNode(plane)
    }
    
    /// Tells the delegate that a SceneKit node's properties have been updated to match the current state of its corresponding anchor.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = self.planes[anchor.identifier],
        let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        plane.update(anchor: planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        self.planes.removeValue(forKey: anchor.identifier)
    }

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
