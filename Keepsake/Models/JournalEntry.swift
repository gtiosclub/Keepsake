//
//  JournalEntry.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation
import SwiftUI

struct JournalEntry: Encodable {
    var date: String
    var title: String
    var text: String
    var summary: String
    var width: Int
    var height: Int
    var isFake: Bool
    var color: [Double]
    var frameWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.38 * CGFloat(width) + UIScreen.main.bounds.width * 0.02 * CGFloat(width - 1)
    }
    var frameHeight: CGFloat {
        return UIScreen.main.bounds.height * 0.12 * CGFloat(height) + UIScreen.main.bounds.width * 0.02 * CGFloat(height - 1)
    }
    
    init(date: String, title: String, text: String, summary: String) {
        self.date = date
        self.text = text
        self.title = title
        self.summary = summary
        self.width = 1
        self.height = 1
        self.isFake = false
        self.color = [0.5,0.5,0.5]
    }
    
    init(date: String, title: String, text: String, summary: String, width: Int, height: Int, isFake: Bool, color: [Double]) {
        self.date = date
        self.text = text
        self.title = title
        self.summary = summary
        self.width = width
        self.height = height
        self.isFake = isFake
        self.color = color
    }
    
    init() {
        self.date = "01/01/2000"
        self.title = "Title"
        self.text = "Text"
        self.summary = "Summary"
        self.width = 1
        self.height = 1
        self.isFake = true
        self.color = [0.5, 0.5, 0.5]
    }
    
    init(entry: JournalEntry, width: Int, height: Int, color: [Double]) {
        self.date = entry.date
        self.title = entry.title
        self.text = entry.title
        self.summary = entry.summary
        self.width = width
        self.height = height
        self.isFake = false
        self.color = color
    }
}

extension JournalEntry {
    func toDictionary() -> [String: Any] {
        return [
            "date": date,
            "title": title,
            "text": text,
            "summary": summary
        ]
    }
}
