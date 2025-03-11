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

extension JournalPage {
    func toDictionary() -> [String: Any] {
        return [
            "number": number,
            "entries": entries.map { $0.toDictionary() } // Assuming JournalEntry has toDictionary()
        ]
    }
}
