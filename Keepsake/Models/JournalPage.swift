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
    
    init(number: Int) {
        let fakeEntry = JournalEntry(date: "", title: "", text: "", summary: "", width: 1, height: 1, isFake: true, color: [0.5, 0.5, 0.5])
        self.number = number
        self.entries = [fakeEntry, fakeEntry, fakeEntry, fakeEntry, fakeEntry, fakeEntry, fakeEntry, fakeEntry]
        self.realEntryCount = 0
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
}
