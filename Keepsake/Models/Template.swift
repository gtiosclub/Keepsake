//
//  Template.swift
//  Keepsake
//
//  Created by Alec Hance on 2/5/25.
//

import Foundation
import SwiftUICore

struct Template {
    var name: String = "Default"
    var coverColor: Color
    var pageColor: Color
    var titleColor: Color
    //insert other TBD variables like color, line type, etc
//    
    init(name: String, coverColor: Color, pageColor: Color, titleColor: Color) {
        self.name = name
        self.coverColor = coverColor
        self.pageColor = pageColor
        self.titleColor = titleColor
    }
    
    // Overloaded initializers
    init(coverColor: Color, pageColor: Color, titleColor: Color) {
        self.init(name: "Default", coverColor: coverColor, pageColor: pageColor, titleColor: titleColor)
    }

    init() {
        self.init(name: "Default", coverColor: .blue, pageColor: .white, titleColor: .black)
    }
}
