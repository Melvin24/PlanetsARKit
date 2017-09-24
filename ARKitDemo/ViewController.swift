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
    
    var sunNode: SunNode?
    var sunNodeHalo: SunHaloNode?
    
    var selectedNode: SCNNode?
    var hitResultWorldCoordinate: SCNVector3?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapGestureRecogniser(for: sceneView)
        setupPanGestureRecogniser(for: sceneView)
        
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
        
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    /// Tells the delegate that a SceneKit node corresponding to a new AR anchor has been added to the scene.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
        
    }
    
    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    }
    
    func setupTapGestureRecogniser(for sceneView: ARSCNView) {
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        sceneView.addGestureRecognizer(tapGestureRec)
    }
    
    func setupPanGestureRecogniser(for sceneView: ARSCNView) {
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gestureRecogniser:)))
        sceneView.addGestureRecognizer(panGestureRecogniser)
    }
    
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)

        let nodeHitResult = sceneView.hitTest(tapPoint, options: nil)
        
        if let firstHitNode = nodeHitResult.first {
            self.selectedNode = firstHitNode.node
            self.hitResultWorldCoordinate = firstHitNode.worldCoordinates
        }
        
        let hitResult = sceneView.hitTest(tapPoint, types: [.featurePoint])
        guard sunNode == nil, let closestHitResult = hitResult.first  else {
            return
        }

        sunNode = SunNode()
        sunNodeHalo = SunHaloNode()
        
//        sunNode?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        let sunTexturAnim = CABasicAnimation.init(keyPath: "contentsTransform")
        
        // Achieve a lava effect by animating textures
        sunTexturAnim.duration = 0.2;
        sunTexturAnim.fromValue = NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0),
                                                                             CATransform3DMakeScale(3, 3, 3)
                                                                            )
                                         )
        sunTexturAnim.toValue = NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0),
                                                                             CATransform3DMakeScale(3, 3, 3)
            )
        )

        sunTexturAnim.repeatCount = .greatestFiniteMagnitude
        
        sunNode?.geometry?.firstMaterial?.diffuse.addAnimation(sunTexturAnim, forKey: "sun-texture")
        
        sunNode?.addChildNode(sunNodeHalo!)
        setPosition(hitResult: closestHitResult, withNode: sunNode!)

        sceneView.scene.rootNode.addChildNode(sunNode!)

    }
    
    @objc func handlePanGesture(gestureRecogniser: UIPanGestureRecognizer) {
        
        switch gestureRecogniser.state {
        case .changed:
            
            guard let selectedNode = self.sunNode else {
                return
            }
//
            let currentPosition = selectedNode.position
            
            print("MELVIN", gestureRecogniser.location(in: sceneView))
//            let location = gestureRecogniser.location(in: sceneView)
            let moveAction = SCNAction.moveBy(x: 0, y: -0.8, z: -0.2, duration: 0.5)
            
            selectedNode.runAction(moveAction)
            
//            let newPosition = SCNVector3Make(currentPosition.x + 0.1, currentPosition.y, currentPosition.z)
//
//            sunNode?.position = newPosition
//            let unprojectedPoint = self.sceneView.unprojectPoint(SCNVector3Make(location.x, location.y, <#T##z: Float##Float#>))
            
        default:
            return
        }
        
    }
    
    func setPosition(hitResult: ARHitTestResult, withNode node: SCNNode) {
        
        node.position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + 0.2,
            hitResult.worldTransform.columns.3.z
        )
        
    }

    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect feature points."
            
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
