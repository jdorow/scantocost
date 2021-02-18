//  extensions.swift
//  Scan To Cost Progress
//  Created by Julian on 06.01.21.

import Foundation
import ARKit

@available(iOS 12.0, *)
extension ARPlaneAnchor.Classification {
    var description: String{
        switch self {
        case .wall:
            return "Wall"
        case .floor:
            return "Floor"
        case .ceiling:
            return "Ceiling"
        case .table:
            return "Table"
        case .seat:
            return "Seat"
        case .none(.unknown):
            return "Unknown"
        default:
            return ""
        }
    }
    
    
    var ClassMaterial: String {
        switch self {
        case .wall:
            return "overlay_wall.png"
        default:
            return ""
        }
        
    }
    

}

struct wall: Identifiable {
    var id: String
    let name: String
    let width: String
    let area: String
    let price: String
    let color: UIColor
}


/*extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = float3(max) - float3(min)
        simdPivot = float4x4(translation: ((extents / 2) + float3(min)))
    }
}

extension float4x4 {
    init(translation vector: float3) {
        self.init(float4(1, 0, 0, 0),
                  float4(0, 1, 0, 0),
                  float4(0, 0, 1, 0),
                  float4(vector.x, vector.y, vector.z, 1))
    }
}*/
