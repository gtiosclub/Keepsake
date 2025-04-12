//
//  Template.swift
//  Keepsake
//
//  Created by Alec Hance on 2/5/25.
//

import Foundation
import SwiftUICore
import UIKit

extension Color {
    func toRGBArray() -> [CGFloat] {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return [0, 0, 0, 1] // Default to black with full opacity if conversion fails
        }
        return [components[0], components[1], components[2], components.count > 3 ? components[3] : 1.0]
    }
}

extension Color {
    static func fromRGBArray(_ array: [CGFloat]) -> Color {
        return Color(
            red: Double(array[0]),
            green: Double(array[1]),
            blue: Double(array[2]),
            opacity: Double(array.count > 3 ? array[3] : 1.0)
        )
    }
}

enum Texture: String {
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

    static func fromDictionary(_ dict: [String: Any]) -> Texture? {
        guard let type = dict["type"] as? String else { return nil }
        return Texture(rawValue: type)
    }
}

extension Texture: CaseIterable, Identifiable {
    var id: String { self.rawValue }
}

struct Template {
    var id: UUID
    var name: String = "Default"
    var coverColor: Color
    var pageColor: Color
    var titleColor: Color
    var texture: Texture
    var journalPages: [JournalPage]?
    //insert other TBD variables like color, line type, etc
//    
    init(name: String, coverColor: Color, pageColor: Color, titleColor: Color, texture: Texture, journalPages: [JournalPage]? = nil) {
        self.id = UUID()
        self.name = name
        self.coverColor = coverColor
        self.pageColor = pageColor
        self.titleColor = titleColor
        self.texture = texture
        self.journalPages = journalPages
    }
    
    // Overloaded initializers
    init(coverColor: Color, pageColor: Color, titleColor: Color) {
        self.init(name: "Default", coverColor: coverColor, pageColor: pageColor, titleColor: titleColor, texture: .leather, journalPages: nil)
    }

    init() {
        self.init(name: "Default", coverColor: .blue, pageColor: .white, titleColor: .black, texture: .leather, journalPages: nil)
    }
}

extension Template: CustomStringConvertible {
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
    
    // Convert Hex string to Color
        private static func hexToColor(hex: String) -> Color {
            let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&int)
            let a, r, g, b: Double
            switch hexSanitized.count {
            case 8: // ARGB
                a = Double((int >> 24) & 0xff) / 255.0
                r = Double((int >> 16) & 0xff) / 255.0
                g = Double((int >> 8) & 0xff) / 255.0
                b = Double(int & 0xff) / 255.0
            case 6: // RGB
                a = 1.0
                r = Double((int >> 16) & 0xff) / 255.0
                g = Double((int >> 8) & 0xff) / 255.0
                b = Double(int & 0xff) / 255.0
            default:
                return .black
            }
            return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
        }
    
    // Convert Template to a dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "coverColor": coverColor.toRGBArray(),
            "pageColor": pageColor.toRGBArray(),
            "titleColor": titleColor.toRGBArray(),
            "texture": texture.toDictionary()
        ]
        
        if let pages = journalPages {
            dict["pages"] = pages.map { $0.toDictionary() }
        }
        
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Template? {
        guard let name = dict["name"] as? String,
                  let textureDict = dict["texture"] as? [String: Any] else {
                return nil
            }
            
            // Move `??` defaults outside `guard let`
            let coverColorArray = dict["coverColor"] as? [CGFloat] ?? [0, 0, 0, 1]
            let pageColorArray = dict["pageColor"] as? [CGFloat] ?? [1, 1, 1, 1]
            let titleColorArray = dict["titleColor"] as? [CGFloat] ?? [0, 0, 0, 1]
            
            // Ensure `Texture.fromDictionary` doesn't return nil
            guard let texture = Texture.fromDictionary(textureDict) else {
                return nil
            }
            
            // Decode journal pages if available
            var journalPages: [JournalPage]?
            if let journalPagesArray = dict["journalPages"] as? [[String: Any]] {
                journalPages = journalPagesArray.compactMap { JournalPage.fromDictionary($0) }
            }

            return Template(
                name: name,
                coverColor: Color.fromRGBArray(coverColorArray),
                pageColor: Color.fromRGBArray(pageColorArray),
                titleColor: Color.fromRGBArray(titleColorArray),
                texture: texture,
                journalPages: journalPages
            )
    }
    
//    var description: String {
//        return "Template(name: \(name), coverColor: \(coverColor), pageColor: \(pageColor), titleColor: \(titleColor), texture: \(texture))"
//    }
//    
    var description: String {
        let pagesDescription = journalPages?.map { $0.description }.joined(separator: ", ") ?? "nil"
        return "Template(name: \(name), coverColor: \(coverColor), pageColor: \(pageColor), titleColor: \(titleColor), texture: \(texture), pages: [\(pagesDescription)])"
    }
}
