//
//  JournalPage.swift
//  Keepsake
//
//  Created by Alec Hance on 2/13/25.
//

import Foundation
import SwiftUI

class JournalPage: ObservableObject {
    var number: Int
    @Published var entries: [JournalEntry]
    var realEntryCount: Int
    @Published var placedStickers: [Sticker]
    
    init(number: Int, entries: [JournalEntry], realEntryCount: Int, placedStickers: [Sticker] = []) {
        self.number = number
        self.entries = entries
        self.realEntryCount = realEntryCount
        self.placedStickers = placedStickers
    }
    
    convenience init(number: Int) {
        self.init(number: number, entries: [JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 0)
    }
    
    convenience init(number: Int, page: JournalPage) {
        self.init(number: number, entries: page.entries, realEntryCount: page.realEntryCount)
    }
}

extension JournalPage: CustomStringConvertible {
    
    func toDictionary() -> [String: Any] {
        return [
            "number": number,
            "entries": entries.filter { $0.isFake }.map { $0.toDictionary() },
            "realEntryCount": realEntryCount
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> JournalPage? {
        guard let number = dict["number"] as? Int,
              let entriesArray = dict["entries"] as? [[String: Any]],
              let realEntryCount = dict["realEntryCount"] as? Int else {
            return nil
        }
        
        var entries = entriesArray.compactMap { JournalEntry.fromDictionary($0) }
        
        switch entries.count {
        case 0: entries = [JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()]
        case 1: entries = [entries[0], JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()]
        case 2: entries = [entries[0], JournalEntry(), JournalEntry(), JournalEntry(), entries[1], JournalEntry(), JournalEntry(), JournalEntry()]
        case 3: entries = [entries[0], entries[1], JournalEntry(), JournalEntry(), entries[3], JournalEntry(), JournalEntry(), JournalEntry()]
        case 4: entries = [entries[0], entries[1], JournalEntry(), entries[2], entries[3], JournalEntry(), JournalEntry(), JournalEntry()]
        case 5: entries = [entries[0], entries[1], JournalEntry(), entries[2], entries[3], JournalEntry(), entries[4], JournalEntry()]
        case 6: entries = [entries[0], entries[1], JournalEntry(), entries[2], entries[3], JournalEntry(), entries[4], entries[5]]
        case 7: entries = [entries[0], entries[1], JournalEntry(), entries[2], entries[3], entries[4], entries[5], entries[6]]
        default: entries = [entries[0], entries[1], entries[2], entries[3], entries[4], entries[5], entries[6], entries[7]]
        }
        
        return JournalPage(number: number, entries: entries, realEntryCount: realEntryCount)
    }
    
    var description: String {
        return "JournalPage(number: \(number), entries: \(entries), realEntryCount: \(realEntryCount))"
    }
    
    static func randomColorOffset(from baseColor: [Double], maxOffset: Double = 0.1) -> [Double] {
        return baseColor.map { component in
            // Generate a random offset between -maxOffset and +maxOffset
            let offset = Double.random(in: -maxOffset...maxOffset)
            // Apply the offset and clamp between 0 and 1
            return max(0, min(1, component + offset))
        }
    }
    
    // Widget Templates
    // Template #1
    static func dailyReflectionTemplate(pageNumber: Int, color: Color) -> JournalPage {
        var entries: [JournalEntry] = []
        
        
        // Image
        let image = PictureEntry(date: todaysdate(), title: "Pics of the Day", images: [], width: 1, height: 2, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(image)
        
        // Prompt
        let prompt = WrittenEntry(date: todaysdate(), title: "Prompt of the Day", text: "", summary: "Imagine that you’re a famous inventor. What would you invent and why?", width: 1, height: 1, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(prompt)
        entries += Array(repeating: WrittenEntry(date: "", title: "", text: "", summary: "", width: 1, height: 1, isFake: true, color: [0.5, 0.5, 0.5]), count: 1)
        
        // Memo
        let memo = VoiceEntry(date: todaysdate(), title: "Memo 1", audio: nil, width: 1, height: 1, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(memo)
        
        // Daily Reflection
        let reflection = WrittenEntry(date: todaysdate(), title: "Daily Reflection", text: "", summary: "How was your day today?", width: 2, height: 2, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(reflection)
        entries.append(JournalEntry())
        entries.append(JournalEntry())
        entries.append(JournalEntry())
        
        
        return JournalPage(number: pageNumber, entries: entries, realEntryCount: 4)
    }
    
    // Template #2
    static func tripTemplate(pageNumber: Int, color: Color) -> JournalPage {
        var entries: [JournalEntry] = []
        
        // Image 1
        let image = PictureEntry(date: todaysdate(), title: "Pics of the Trip", images: [], width: 1, height: 2, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(image)
        
        // Prompt
        let prompt = WrittenEntry(date: todaysdate(), title: "Summarize your trip", text: "", summary: "Give a summary of your trip here", width: 1, height: 1, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(prompt)
        entries += Array(repeating: WrittenEntry(date: "", title: "", text: "", summary: "", width: 1, height: 1, isFake: true, color: [0.5, 0.5, 0.5]), count: 1)
        
        // Memo
        let memo = VoiceEntry(date: todaysdate(), title: "Memo 1", audio: nil, width: 1, height: 1, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(memo)
        
        // Daily Reflection
        let reflection = WrittenEntry(date: todaysdate(), title: "Daily Reflections of Trip", text: "", summary: "How was each day?", width: 2, height: 1, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(reflection)
        entries += Array(repeating: WrittenEntry(date: todaysdate(), title: "", text: "", summary: "", width: 1, height: 1, isFake: true, color: [0.5, 0.8, 0.5]), count: 1)
        
        // Image 2
        let image2 = PictureEntry(date: todaysdate(), title: "Pics of the Trip", images: [], width: 1, height: 1, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(image2)
        
        // Image 3
        let image3 = PictureEntry(date: todaysdate(), title: "Pics of the Trip", images: [], width: 1, height: 1, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(image3)
        
        return JournalPage(number: pageNumber, entries: entries, realEntryCount: 6)
    }
    
    // Template #2
    static func defaultTemplate(pageNumber: Int, color: Color) -> JournalPage {
        var entries: [JournalEntry] = []
        
        // Daily Reflection
        let text = WrittenEntry(date: todaysdate(), title: "Text", text: "", summary: "Default Summary", width: 1, height: 2, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(text)
        
        // Memo
        let memo = VoiceEntry(date: todaysdate(), title: "Memo 1", audio: nil, width: 1, height: 2, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(memo)
        
        entries.append(JournalEntry())
        entries.append(JournalEntry())
        
        // Image 1
        let image = PictureEntry(date: todaysdate(), title: "Default Pics", images: [], width: 2, height: 2, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ))
        entries.append(image)
        
        entries.append(JournalEntry())
        entries.append(JournalEntry())
        entries.append(JournalEntry())
        
        return JournalPage(number: pageNumber, entries: entries, realEntryCount: 3)
    }
    
    static func previewTemplate(pageNumber: Int, color: Color) -> JournalPage {
        var entries: [JournalEntry] = []
        
        let entry1 = JournalEntry(date: "", title: "", entryContents: "", width: 1, height: 2, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ), type: .blank)
        entries.append(entry1)
        
        let entry2 = JournalEntry(date: "", title: "", entryContents: "", width: 1, height: 1, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ), type: .blank)
        entries.append(entry2)
        entries.append(JournalEntry())
        
        let entry3 = JournalEntry(date: "", title: "", entryContents: "", width: 1, height: 1, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ), type: .blank)
        entries.append(entry3)
        
        let entry4 = JournalEntry(date: "", title: "", entryContents: "", width: 2, height: 2, isFake: false, color: randomColorOffset(
            from: color.toRGBArray().map(Double.init)
        ), type: .blank)
        entries.append(entry4)
        entries.append(JournalEntry())
        entries.append(JournalEntry())
        entries.append(JournalEntry())
        
        return JournalPage(number: pageNumber, entries: entries, realEntryCount: 4)
    }
    
}
