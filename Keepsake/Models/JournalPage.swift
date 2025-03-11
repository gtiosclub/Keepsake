//
//  JournalPage.swift
//  Keepsake
//
//  Created by Alec Hance on 2/13/25.
//

import Foundation

class JournalPage: Encodable {
    var number: Int
    var entries: [JournalEntry]
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
            "entries": entries.map { $0.toDictionary() } // Assuming JournalEntry has toDictionary()
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> JournalPage? {
        guard let number = dict["number"] as? Int,
              let entriesArray = dict["entries"] as? [[String: Any]],
              let realEntryCount = dict["realEntryCount"] as? Int else {
            return nil
        }

        let entries = entriesArray.compactMap { JournalEntry.fromDictionary($0) }

        return JournalPage(number: number, entries: entries, realEntryCount: realEntryCount)
    }
    
    var description: String {
        return "JournalPage(number: \(number), entries: \(entries), realEntryCount: \(realEntryCount))"
    }
}
