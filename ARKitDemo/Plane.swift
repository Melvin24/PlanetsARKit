//
//  Plane.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 05/09/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane
    
    init(withAnchor anchor: ARPlaneAnchor, hidden: Bool) {
        
        self.anchor = anchor
        
        let width = CGFloat(anchor.extent.x)
        let height = CGFloat(anchor.extent.z)
        
        planeGeometry = SCNPlane(width: width, height: height)
        
        super.init()
    
        self.planeGeometry.materials = [tronMaterial()]
        
        let planeNode = SCNNode(geometry: planeGeometry)
        
        let x = CGFloat(anchor.center.x)
        let z = CGFloat(anchor.center.z)
        
        planeNode.position = SCNVector3(x, 0, z)
        
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, so
         rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
         */
        planeNode.eulerAngles.x = -.pi / 2
        
        // Give the plane a physics body so that items we add to the scene interact with it
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        
        setTextureScale()
        
        addChildNode(planeNode)
        
        
    }
    
    func tronMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        let image = UIImage(named: "tron_grid")
        material.diffuse.contents = image
        return material
    }
    
    func setTextureScale() {
        let width = Float(planeGeometry.width)
        let height = Float(planeGeometry.height)
        
        // As the width/height of the plane updates, we want our tron grid material to
        // cover the entire plane, repeating the texture over and over. Also if the
        // grid is less than 1 unit, we don't want to squash the texture to fit, so
        // scaling updates the texture co-ordinates to crop the texture in that case
        let material = planeGeometry.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1);
        material?.diffuse.wrapS = .repeat;
        material?.diffuse.wrapT = .repeat;
    }
    
    func update(anchor: ARPlaneAnchor) {
        
        simdPosition = float3(anchor.center.x, 0, anchor.center.z)

        /*
         Plane estimation may extend the size of the plane, or combine previously detected
         planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
         corresponding node for one plane, then calls this method to update the size of
         the remaining plane.
         */
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)

//        position = SCNVector3(anchor.center.x, 0, anchor.center.z);
        
        setTextureScale()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
