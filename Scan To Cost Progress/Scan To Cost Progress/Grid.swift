//
//  Grid.swift
//  NextReality_Tutorial7
//
//  Created by Ambuj Punn on 5/2/18.
//  Copyright © 2018 Ambuj Punn. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import MetalKit
import UIKit
import SwiftUI

// 5.2
extension ARPlaneAnchor {
    
    
    var width: Float { return self.extent.x}
    var length: Float { return self.extent.z}
    var area: CGFloat { return CGFloat(self.width * self.length)}
    
    
}
    
class Grid : SCNNode {
    

    var anchor: ARPlaneAnchor
    var FL: CGFloat
    var RH: CGFloat
    var CL: CGFloat
    var Wandmitte: CGFloat
    var planeGeometry: SCNPlane!
    var cost: CGFloat
    // 5.1
    var textGeometry: SCNText!
    var gridslist = [Grid]()

    
    init(anchor: ARPlaneAnchor, floorlevel: CGFloat, ceilinglevel: CGFloat, roomheight: CGFloat, grids: [Grid], price: CGFloat) {
        
        // import Parameter aus View Controller
        self.anchor = anchor
        gridslist = grids
        cost = price
        FL = floorlevel
        CL = ceilinglevel
        RH = roomheight
        Wandmitte = RH/2+FL
        
        super.init()
        
        setup()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func update(anchor: ARPlaneAnchor) {
        
        planeGeometry.width = CGFloat(anchor.extent.x);
        planeGeometry.height = CGFloat(anchor.length);
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        
        // Preis
        let price = anchor.area * cost
        
        // ID
        let newid = gridslist.count
        
        // Update Plane
        let planeNode = self.childNodes.first!
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        
        // 5.4
        if let textGeometry = self.childNode(withName: "textNode", recursively: true)?.geometry as? SCNText {
            // Update text to new size
            textGeometry.string =  String(anchor.classification.description) + " " + String(newid + 1) + "\n" + String(format: "%.1fm", anchor.width) + " x " + String(format: "%.1fm", anchor.length) + "\n" + String(format: "%.1fm²", anchor.area) + "\n" + String(format: "%.1f€", price)
            }
        }
    
    // 5.3
    func setup(){
        
        //Raumgeometrien DEBUG
        /*print("Boden", FL)
        print("Decke", CL)
        print ("Wandmitte", Wandmitte)
        print ("Raumhöhe", RH)*/
        
        // Wandmaße
        planeGeometry = SCNPlane(width: CGFloat(anchor.width), height: CGFloat(anchor.length))
        // Preis
        let price = anchor.area * cost
        
        //ID
        let newid = gridslist.count
            
        // Material
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: anchor.classification.ClassMaterial)
        planeGeometry.materials = [material]
        
        //Set Up Plane
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = 2
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);
        
        // Text Farbe
        // 1.
        let textNodeMaterial = SCNMaterial()
        textNodeMaterial.diffuse.contents = UIColor.black
        
        // Set up text geometry
        textGeometry = SCNText(string: String(anchor.classification.description) + " " + String(newid + 1) + String(format: "%.1fm", anchor.width) + " x " + String(format: "%.1fm", anchor.length) + "\n = " + String(format: "%.1fm²s", anchor.area) + "\n" + String(format: "%.1f€", price), extrusionDepth: 1)
        textGeometry.font = UIFont.systemFont(ofSize: 10)
        textGeometry.materials = [textNodeMaterial]
        
        // Integrate text node with text geometry
        // 2.
        let textNode = SCNNode(geometry: textGeometry)
        textNode.name = "textNode"
        textNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        textNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);
        textNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
        
        addChildNode(textNode)
        addChildNode(planeNode)
        //print(anchor.transform.columns.3)
    }
}
    
