//
//  Template.swift
//  Keepsake
//
//  Created by Alec Hance on 2/5/25.
//

import Foundation
import SwiftUICore
import UIKit

enum Texture {
    case leather
    case bears
    case blackLeather
    case flower1
    case flower2
    case flower3
    case garden
    case green
    case redLeather
    case snoopy
    case stars
    
    func toDictionary() -> [String: Any] {
        switch self {
        case .leather:
            return ["type": "leather"]
        case .bears:
            return ["type": "bears"]
        case .blackLeather:
            return ["type": "blackLeather"]
        case .flower1:
            return ["type": "flower1"]
        case .flower2:
            return ["type": "flower2"]
        case .flower3:
            return ["type": "flower3"]
        case .garden:
            return ["type": "garden"]
        case .green:
            return ["type": "green"]
        case .redLeather:
            return ["type": "redLeather"]
        case .snoopy:
            return ["type": "snoopy"]
        case .stars:
            return ["type": "stars"]
        }
    }
}

struct Template {
    var name: String = "Default"
    var coverColor: Color
    var pageColor: Color
    var titleColor: Color
    var texture: Texture
    //insert other TBD variables like color, line type, etc
//    
    init(name: String, coverColor: Color, pageColor: Color, titleColor: Color, texture: Texture) {
        self.name = name
        self.coverColor = coverColor
        self.pageColor = pageColor
        self.titleColor = titleColor
        self.texture = texture
    }
    
    // Overloaded initializers
    init(coverColor: Color, pageColor: Color, titleColor: Color) {
        self.init(name: "Default", coverColor: coverColor, pageColor: pageColor, titleColor: titleColor, texture: .leather)
    }

    init() {
        self.init(name: "Default", coverColor: .blue, pageColor: .white, titleColor: .black, texture: .leather)
    }
    
    // Convert Color to Hex string
    private func colorToHex(color: Color) -> String {
        // Convert Color to RGBA values
        let uiColor = UIColor(color)
        let red = uiColor.cgColor.components?[0] ?? 0
        let green = uiColor.cgColor.components?[1] ?? 0
        let blue = uiColor.cgColor.components?[2] ?? 0
        let alpha = uiColor.cgColor.components?[3] ?? 1
        
        // Return hex string
        return String(format: "#%02X%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255), Int(alpha * 255))
    }
    
    // Convert Template to a dictionary
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "coverColor": colorToHex(color: coverColor),
            "pageColor": colorToHex(color: pageColor),
            "titleColor": colorToHex(color: titleColor),
            "texture": texture.toDictionary() // Assuming Texture has a `toDictionary()` method
        ]
    }
}
