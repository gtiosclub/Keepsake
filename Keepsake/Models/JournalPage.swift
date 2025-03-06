//
//  JournalPage.swift
//  Keepsake
//
//  Created by Alec Hance on 2/13/25.
//

import Foundation

class JournalPage {
    var number: Int
    var entries: [JournalEntry]
    var realEntryCount: Int
    
    init(number: Int, entries: [JournalEntry]) {
        self.number = number
        self.entries = entries
        self.realEntryCount = entries.count
    }
    
    
}
