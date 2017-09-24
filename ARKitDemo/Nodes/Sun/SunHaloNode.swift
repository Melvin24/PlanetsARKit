//
//  SunHaloNode.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 23/09/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import Foundation
import ARKit

class SunHaloNode: SCNNode {
    
    override init() {
        
        super.init()
        
        geometry = SCNPlane(width: 2.5, height: 2.5)
        
        rotation = SCNVector4Make(1, 0, 0, 0 * .pi / 180.0)
        geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun-halo.png"
        geometry?.firstMaterial?.lightingModel = .constant
        geometry?.firstMaterial?.writesToDepthBuffer = false
        opacity = 0.2
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
