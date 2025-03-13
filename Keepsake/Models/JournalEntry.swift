//
//  JournalEntry.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation
import SwiftUI

enum EntryType: Encodable {
    case written, chat, image, voice
}

struct JournalEntry: Encodable, Hashable {
    var id: UUID
    var date: String
    var title: String
    var text: String
    var summary: String
    var width: Int
    var height: Int
    var isFake: Bool
    var color: [Double]
    var images: [Data]
    var frameWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.38 * CGFloat(width) + UIScreen.main.bounds.width * 0.02 * CGFloat(width - 1)
    }
    var frameHeight: CGFloat {
        return UIScreen.main.bounds.height * 0.12 * CGFloat(height) + UIScreen.main.bounds.width * 0.02 * CGFloat(height - 1)
    }
    var type: EntryType
    
    init(date: String, title: String, text: String, summary: String) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.title = title
        self.summary = summary
        self.width = 1
        self.height = 1
        self.isFake = false
        self.color = [0.5,0.5,0.5]
        self.images = []
        self.type = .written
    }
    
    init(date: String, title: String, text: String, summary: String, width: Int, height: Int, isFake: Bool, color: [Double]) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.title = title
        self.summary = summary
        self.width = width
        self.height = height
        self.isFake = isFake
        self.color = color
        self.images = []
        self.type = .written
    }
    
    init(date: String, title: String, text: String, summary: String, width: Int, height: Int, isFake: Bool, color: [Double], images: [UIImage]) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.title = title
        self.summary = summary
        self.width = width
        self.height = height
        self.isFake = isFake
        self.color = color
        self.images = []
        for image in images {
            if let imageData = image.pngData() {
                    self.images.append(imageData)
            }
        }
        self.type = .image
    }
    
    init() {
        self.id = UUID()
        self.date = "01/01/2000"
        self.title = "Title"
        self.text = "Text"
        self.summary = "Summary"
        self.width = 1
        self.height = 1
        self.isFake = true
        self.color = [0.5, 0.5, 0.5]
        self.images = []
        self.type = .written
    }
    
    init(entry: JournalEntry, width: Int, height: Int, color: [Double], images: [Data], type: EntryType) {
        self.id = UUID()
        self.date = entry.date
        self.title = entry.title
        self.text = entry.text
        self.summary = entry.summary
        self.width = width
        self.height = height
        self.isFake = false
        self.color = color
        self.images = images
        self.type = type
    }
}

extension JournalEntry: CustomStringConvertible {
    func toDictionary() -> [String: Any] {
        return [
            "date": date,
            "title": title,
            "entryContents": text,
            "summary": summary,
            "width": width,
            "height": height,
            "isFake": isFake,
            "color": color,
            "id": id.uuidString
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> JournalEntry? {
        guard let date = dict["date"] as? String,
              let title = dict["title"] as? String,
              let text = dict["entryContents"] as? String,
              let summary = dict["summary"] as? String,
              let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let width = dict["width"] as? Int,
              let height = dict["height"] as? Int,
              let isFake = dict["isFake"] as? Bool,
              let color = dict["color"] as? [Double] else {
            return nil
        }
        
        return JournalEntry(date: date, title: title, text: text, summary: summary, width: width, height: height, isFake: isFake, color: color)
    }
    
    var description: String {
        return "JournalEntry(date: \(date), title: \(title), text: \(text), summary: \(summary), width: \(width), height: \(height), isFake: \(isFake), color: \(color))"
    }
    
}
