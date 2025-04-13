//
//  ScrapbookEntry.swift
//  Keepsake
//
//  Created by Alec Hance on 2/5/25.
//

import RealityKit
import Foundation


struct ScrapbookEntry: Codable {
    let id: UUID
    let type: String
    let position: [Float]
    let scale: Float
    let rotation: [Float]
    let text: String?
    let imageURL: String?
    let frame: String
    let font: String
    let fontSize: Int
    let isBold: Bool
    let isItalic: Bool
    let textColor: [Float]
    let backgroundColor: [Float]

    init(id: UUID, type: String, position: [Float], scale: Float, rotation: [Float], text: String?, imageURL: String?, frame: String = "classic", font: String = "Helvetica", fontSize: Int = 200, isBold: Bool = false, isItalic: Bool = false, textColor: [Float] = [0, 0, 0], backgroundColor: [Float] = [1, 1, 1]) {
        self.id = id
        self.type = type
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.text = text
        self.imageURL = imageURL
        self.frame = frame
        self.font = font
        self.fontSize = fontSize
        self.isBold = isBold
        self.isItalic = isItalic
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}

extension ScrapbookEntry: CustomStringConvertible {
    func toDictionary(scrapbookID: UUID) -> [String: Any] {
        return [
            "scrapbook_id": scrapbookID.uuidString,
            "id": id.uuidString,
            "type": type,
            "position": position,
            "scale": scale,
            "rotation": rotation,
            "text": text as Any,
            "imageURL": imageURL as Any,
            "frame": frame,
            "font": font,
            "fontSize": fontSize,
            "isBold": isBold,
            "isItalic": isItalic,
            "textColor": textColor,
            "backgroundColor": backgroundColor
        ]
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "type": type,
            "position": position,
            "scale": scale,
            "rotation": rotation,
            "text": text as Any,
            "imageURL": imageURL as Any,
            "frame": frame,
            "font": font,
            "fontSize": fontSize,
            "isBold": isBold,
            "isItalic": isItalic,
            "textColor": textColor,
            "backgroundColor": backgroundColor
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> ScrapbookEntry? {
        guard let idString = dict["id"] as? String else {
            print("id problem")
            return nil
        }
        guard let id = UUID(uuidString: idString) else {
            print("id problem")
            return nil
        }
        guard let type = dict["type"] as? String else {
            print("type problem")
            return nil
        }
        
        guard let rawPosition = dict["position"] as? [Any],
              let position = rawPosition as? [NSNumber] else {
            print("position problem")
            return nil
        }

        let floatPosition = position.map { $0.floatValue }
        
        guard let scale = (dict["scale"] as? NSNumber)?.floatValue else {
            print("scale problem")
            return nil
        }
        
        guard let rawRotation = dict["rotation"] as? [Any],
              let rotation = rawRotation as? [NSNumber] else {
            print("rotation problem")
            return nil
        }
        
        let floatRotation = rotation.map { $0.floatValue }
        
        let text = dict["text"] as? String
        let imageURL = dict["imageURL"] as? String
        
        guard let frame = dict["frame"] as? String,
              let font = dict["font"] as? String,
              let fontSize = dict["fontSize"] as? Int,
              let isBold = dict["isBold"] as? Bool,
              let isItalic = dict["isItalic"] as? Bool else {
            return nil
        }
        
        guard let rawTextColor = dict["textColor"] as? [Any],
              let textColor = rawTextColor as? [NSNumber] else {
            return nil
        }
        
        let floatTextColor = textColor.map { $0.floatValue }
        
        guard let rawBackgroundColor = dict["backgroundColor"] as? [Any],
              let backgroundColor = rawBackgroundColor as? [NSNumber] else {
            return nil
        }
        
        let floatBackgroundColor = backgroundColor.map { $0.floatValue }
        
        
        
        return ScrapbookEntry(id: id, type: type, position: floatPosition, scale: scale, rotation: floatRotation, text: text, imageURL: imageURL, frame: frame, font: font, fontSize: fontSize, isBold: isBold, isItalic: isItalic, textColor: floatTextColor, backgroundColor: floatBackgroundColor)
    }
    
    var description: String {
        return "ScrapbookEntry(id: \(id), type: \(type), position: \(position), scale: \(scale), rotation: \(rotation), text: \(text ?? "nil"), imageURL: \(imageURL ?? "nil"))"
    }
}
