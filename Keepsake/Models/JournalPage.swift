//
//  JournalPage.swift
//  Keepsake
//
//  Created by Alec Hance on 2/13/25.
//

import Foundation

class JournalPage: ObservableObject {
    var number: Int
    @Published var entries: [JournalEntry]
    var realEntryCount: Int
    
    init(number: Int, entries: [JournalEntry], realEntryCount: Int) {
        self.number = number
        self.entries = entries
        self.realEntryCount = realEntryCount
    }
    
    convenience init(number: Int) {
        self.init(number: number, entries: [JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 0)
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
    
    // Widget Templates
    // Template #1
    static func dailyReflectionTemplate(pageNumber: Int) -> JournalPage {
        var entries: [JournalEntry] = []
        
        func color(_ r: Double, _ g: Double, _ b: Double) -> [Double] {
            return [r, g, b]
        }
        
        // Image
        let image = JournalEntry(date: "", title: "Pics of the Day", text: "", summary: "Add a pic of the day", width: 1, height: 2, isFake: false, color: color(1.0, 1.0, 1.0))
        entries.append(image)
        
        // Prompt
        let prompt = JournalEntry(date: "", title: "Prompt of the Day", text: "", summary: "Imagine that you’re a famous inventor. What would you invent and why?", width: 1, height: 1, isFake: false, color: color(0.8, 1.0, 1.0))
        entries.append(prompt)
        entries += Array(repeating: JournalEntry(date: "", title: "", text: "", summary: "", width: 1, height: 1, isFake: true, color: [0.5, 0.5, 0.5]), count: 1)
        
        // Memo
        let memo = JournalEntry(date: "", title: "Memo 1", text: "", summary: "Voice memo thoughts here", width: 1, height: 1, isFake: false, color: color(0.9, 1.0, 0.9))
        entries.append(memo)
        
        // Daily Reflection
        let reflection = JournalEntry(date: "", title: "Daily Reflection", text: "", summary: "How was your day today?", width: 2, height: 2, isFake: false, color: color(0.9, 0.85, 1.0))
        entries.append(reflection)
        
        return JournalPage(number: pageNumber, entries: entries, realEntryCount: 4)
    }
    
    // Template #2
    static func springBreakTemplate(pageNumber: Int) -> JournalPage {
        var entries: [JournalEntry] = []
        
        func color(_ r: Double, _ g: Double, _ b: Double) -> [Double] {
            return [r, g, b]
        }
        
        // Image 1
        let image = JournalEntry(date: "", title: "Pic of the trip", text: "", summary: "Add a vertical picture of your trip here.", width: 1, height: 2, isFake: false, color: color(1.0, 1.0, 1.0))
        entries.append(image)
        
        // Prompt
        let prompt = JournalEntry(date: "", title: "Summarize your spring break", text: "", summary: "Give a summary of your trip here", width: 1, height: 1, isFake: false, color: color(0.8, 1.0, 1.0))
        entries.append(prompt)
        entries += Array(repeating: JournalEntry(date: "", title: "", text: "", summary: "", width: 1, height: 1, isFake: true, color: [0.5, 0.5, 0.5]), count: 1)
        
        // Memo
        let memo = JournalEntry(date: "", title: "Memo 1", text: "", summary: "Voice memo thoughts here", width: 1, height: 1, isFake: false, color: color(0.9, 1.0, 0.9))
        entries.append(memo)
        
        // Daily Reflection
        let reflection = JournalEntry(date: "", title: "Daily Reflections of your Spring Break", text: "", summary: "How was each day?", width: 2, height: 1, isFake: false, color: color(0.9, 0.85, 1.0))
        entries.append(reflection)
        entries += Array(repeating: JournalEntry(date: "", title: "", text: "", summary: "", width: 1, height: 1, isFake: true, color: [0.5, 0.5, 0.5]), count: 1)
        
        // Image 2
        let image2 = JournalEntry(date: "", title: "Pic of the trip", text: "", summary: "Add a square picture of your trip here.", width: 1, height: 1, isFake: false, color: color(1.0, 1.0, 1.0))
        entries.append(image2)
        
        // Image 3
        let image3 = JournalEntry(date: "", title: "Pic of the trip", text: "", summary: "Add a square picture of your trip here.", width: 1, height: 1, isFake: false, color: color(1.0, 1.0, 1.0))
        entries.append(image3)
        
        return JournalPage(number: pageNumber, entries: entries, realEntryCount: 6)
    }
    
    
}
