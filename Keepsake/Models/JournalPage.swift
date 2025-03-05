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
    
    init(number: Int, entries: [JournalEntry]) {
        self.number = number
        self.entries = entries
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
