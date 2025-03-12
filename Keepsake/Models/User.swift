//
//  User.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation

class User: Identifiable, ObservableObject {
    var id: String
    var name: String
    @Published var journalShelves: [JournalShelf]
    @Published var scrapbookShelves: [ScrapbookShelf]
    
    init(id: String, name: String, journalShelves: [JournalShelf], scrapbookShelves: [ScrapbookShelf]) {
        self.id = id
        self.name = name
        self.journalShelves = journalShelves
        self.scrapbookShelves = scrapbookShelves
    }
    
    // Provide default values for id and name
    init(journalShelves: [JournalShelf] = [], scrapbookShelves: [ScrapbookShelf] = []) {
        self.id = UUID().uuidString
        self.name = "Default User"
        self.journalShelves = journalShelves
        self.scrapbookShelves = scrapbookShelves
    }
    
    func updateJournalEntry(shelfNum: Int, bookNum: Int, pageNum: Int, entryNum: Int, newEntry: JournalEntry) {
        var journal = (journalShelves[shelfNum].journals[bookNum])
        journal.pages[pageNum].entries[entryNum] = newEntry
        journalShelves[shelfNum].journals[bookNum] = journal
    }
    
    func addJournalShelf(shelf: JournalShelf) {
        self.journalShelves.append(shelf)
    }
    
    func getJournalShelves() -> [JournalShelf] {
        return self.journalShelves
    }
}
