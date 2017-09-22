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
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    
    // A dictionary of all the current planes being rendered in the scene
    var planes: [UUID : Plane] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapGestureRecogniser(for: sceneView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            sessionInfoLabel.text = "ARKit Not Supported"
            return
        }
        
        setupView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupView() {
        /*
         Start the view's AR session with a configuration that uses the rear camera,
         device position and orientation tracking, and plane detection.
         */
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        sceneView.delegate = self
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    /// Tells the delegate that a SceneKit node corresponding to a new AR anchor has been added to the scene.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = Plane(withAnchor: planeAnchor, hidden: false)
        self.planes[planeAnchor.identifier] = plane
        node.addChildNode(plane)
        
    }
    
    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let plane = planes[anchor.identifier],
              let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        plane.update(anchor: planeAnchor)

    }
    
    func setupTapGestureRecogniser(for sceneView: ARSCNView) {
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        sceneView.addGestureRecognizer(tapGestureRec)
    }
//
//    // Contains a list of all the boxes rendered in the scene
//    var boxes: [SCNNode] = []
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)

        let hitResult = sceneView.hitTest(tapPoint, types: [.existingPlaneUsingExtent])
        guard hitResult.count > 0  else {
            return
        }

        // If there are multiple hits, just pick the closest plane
        let closestHitResult = hitResult[0]

        let node = nodeAt(hitResult: closestHitResult)

//        guard let scene = SCNScene(named: "art.scnassets/ship.scn"),
//              let shipNode = scene.rootNode.childNode(withName: "ship", recursively: true) else {
//            return
//        }
//
//        shipNode.scale = SCNVector3(x: 0.25, y: 0.25, z: 0.25)
//
//        shipNode.position = SCNVector3Make(
//            closestHitResult.worldTransform.columns.3.x,
//            closestHitResult.worldTransform.columns.3.y + 0.3,
//            closestHitResult.worldTransform.columns.3.z
//        )

        sceneView.scene.rootNode.addChildNode(node)
//        sceneView.scene.rootNode.addChildNode(sceneNode)

//        boxeqs.append(node)

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
            hitResult.worldTransform.columns.3.y + 0.2,
            hitResult.worldTransform.columns.3.z
        )

        return node
    }


    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal surfaces."
            
        case .normal:
            // No feedback needed when tracking is normal and planes are visible.
            message = ""
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension ViewController: ARSessionDelegate {
    
    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
}
