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
    
    init() {
        self.name = "Default"
        self.coverColor = .blue
        self.pageColor = .white
        self.titleColor = .black
    }
}
