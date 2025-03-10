//
//  Template.swift
//  Keepsake
//
//  Created by Alec Hance on 2/5/25.
//

import Foundation
import SwiftUICore

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
}
