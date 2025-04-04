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
    let rotation: Float
    let text: String?
    let imageURL: String?

    init(id: UUID, type: String, position: [Float], scale: Float, rotation: Float, text: String?, imageURL: String?) {
        self.id = id
        self.type = type
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.text = text
        self.imageURL = imageURL
    }
}
//struct CodableQuaternion: Codable {
//    let vector: SIMD4<Float> // simd_quatf is stored as a SIMD4
//
//    init(_ quaternion: simd_quatf) {
//        self.vector = quaternion.vector
//    }
//
//    var quaternion: simd_quatf {
//        return simd_quatf(vector: vector)
//    }
//}

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
            "imageURL": imageURL as Any
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
            "imageURL": imageURL as Any
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> ScrapbookEntry? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let type = dict["type"] as? String,
              let position = dict["position"] as? [Float],
              let scale = dict["scale"] as? Float,
              let rotation = dict["rotation"] as? Float else {
            return nil
        }
        
        let text = dict["text"] as? String
        let imageURL = dict["imageURL"] as? String
        
        return ScrapbookEntry(id: id, type: type, position: position, scale: scale, rotation: rotation, text: text, imageURL: imageURL)
    }
    
    var description: String {
        return "ScrapbookEntry(id: \(id), type: \(type), position: \(position), scale: \(scale), rotation: \(rotation), text: \(text ?? "nil"), imageURL: \(imageURL ?? "nil"))"
    }
}
