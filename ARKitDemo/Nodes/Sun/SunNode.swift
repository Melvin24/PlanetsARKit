//
//  Sun.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 23/09/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class SunNode: SCNNode {
    
    override init() {
        super.init()

        self.geometry = SCNSphere(radius: 0.15)
        
        self.geometry?.firstMaterial?.multiply.contents = "art.scnassets/sun.jpg"
        self.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun.jpg"
        self.geometry?.firstMaterial?.multiply.intensity = 0.5
        self.geometry?.firstMaterial?.lightingModel = .constant

        self.geometry?.firstMaterial?.multiply.wrapS = .repeat
        self.geometry?.firstMaterial?.diffuse.wrapS  = .repeat
        self.geometry?.firstMaterial?.multiply.wrapT = .repeat
        self.geometry?.firstMaterial?.diffuse.wrapT  = .repeat

        self.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

