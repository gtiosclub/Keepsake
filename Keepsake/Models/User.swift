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
    @Published var savedTemplates: [Template]
    
    init(id: String, name: String, journalShelves: [JournalShelf], scrapbookShelves: [ScrapbookShelf], savedTemplates: [Template] = []) {
        self.id = id
        self.name = name
        self.journalShelves = journalShelves
        self.scrapbookShelves = scrapbookShelves
        self.savedTemplates = savedTemplates

    }
    
    // Provide default values for id and name
    init(journalShelves: [JournalShelf] = [], scrapbookShelves: [ScrapbookShelf] = [], savedTemplates: [Template] = []) {
        self.id = UUID().uuidString
        self.name = "Default User"
        self.journalShelves = journalShelves
        self.scrapbookShelves = scrapbookShelves
        self.savedTemplates = []

    }
    
    func updateJournalEntry(shelfNum: Int, bookNum: Int, pageNum: Int, entryNum: Int, newEntry: JournalEntry) {
        var journal = (journalShelves[shelfNum].journals[bookNum])
        journal.pages[pageNum].entries[entryNum] = newEntry
        journalShelves[shelfNum].journals[bookNum] = journal
    }
    
    func addJournalShelf(shelf: JournalShelf) {
        self.journalShelves.append(shelf)
    }
    
    func addScrapbookShelf(shelf: ScrapbookShelf) {
        self.scrapbookShelves.append(shelf)
    }
    
    func getJournalShelves() -> [JournalShelf] {
        return self.journalShelves
    }
    
    func getScrapbookShelves() -> [ScrapbookShelf] {
        return self.scrapbookShelves
    }
}
