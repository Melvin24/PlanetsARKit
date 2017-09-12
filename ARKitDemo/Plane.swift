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
    var planeGeometry: SCNBox
    
    init(withAnchor anchor: ARPlaneAnchor, hidden: Bool) {
        
        self.anchor = anchor
        
        let width = CGFloat(anchor.extent.x)
        let length = CGFloat(anchor.extent.z)
        
        // For the physics engine to work properly give the plane some height so we get interactions
        // between the plane and the gometry we add to the scene
        let planeHeight: Float = 0.01
        
        planeGeometry = SCNBox(width: width, height: CGFloat(planeHeight), length: length, chamferRadius: 0)
        
        super.init()
    
        
        let materialTronStyle = tronMaterial()
        
        // Since we are using a cube, we only want to render the tron grid
        // on the top face, make the other sides transparent
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor(white: 1, alpha: 0)
        
        let materials: [SCNMaterial]
        
        if hidden {
            materials = Array(repeating: transparentMaterial, count: 6)
        } else {
            var finalMaterials = Array(repeating: transparentMaterial, count: 4)
            finalMaterials.append(materialTronStyle)
            finalMaterials.append(transparentMaterial)
            
            materials = finalMaterials
        }
        
        self.planeGeometry.materials = materials
        
        let planeNode = SCNNode(geometry: planeGeometry)
        
        planeNode.position = SCNVector3(0, 0, 0)
        
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
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)

        position = SCNVector3(anchor.center.x, 0, anchor.center.z);
        
        setTextureScale()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
