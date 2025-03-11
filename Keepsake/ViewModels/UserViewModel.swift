//
//  UserViewModel.swift
//  Keepsake
//
//  Created by Alec Hance on 2/28/25.
//

import Foundation

class UserViewModel: ObservableObject {
    @Published var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func addJournalShelfToUser(_ shelf: JournalShelf) {
        user.addJournalShelf(shelf: shelf)
    }
    
    func getJournalShelves() -> [JournalShelf] {
        return user.getJournalShelves()
    }
    
    func getJournal(shelfIndex: Int, bookIndex: Int) -> Journal {
        return user.getJournalShelves()[shelfIndex].journals[bookIndex]
    }
    
    func getJournalEntry(shelfIndex: Int, bookIndex: Int, pageNum: Int, entryIndex: Int) -> JournalEntry {
        return user.getJournalShelves()[shelfIndex].journals[bookIndex].pages[pageNum].entries[entryIndex]
    }
    
    func updateJournalEntry(shelfIndex: Int, bookIndex: Int, pageNum: Int, entryIndex: Int, newEntry: JournalEntry) {
        user.getJournalShelves()[shelfIndex].journals[bookIndex].pages[pageNum].entries[entryIndex] = newEntry
    }
    
    func newAddJournalEntry(journal: Journal, pageNum: Int, entry: JournalEntry) -> Int {
        let page = journal.pages[pageNum]
        var entrySelection = 0
        switch page.realEntryCount {
        case 0:
            page.entries[0] = JournalEntry(entry: entry, width: 2, height: 2, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 0
        case 1:
            page.entries[4] = JournalEntry(entry: entry, width: 2, height: 2, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 4
        case 2:
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 1, height: 2, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
            page.entries[1] = JournalEntry(entry: entry, width: 1, height: 2, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 1
        case 3:
            page.entries[1] = JournalEntry(entry: page.entries[1], width: 1, height: 1, color: page.entries[1].color, images: page.entries[1].images, type: page.entries[0].type)
            page.entries[3] = JournalEntry(entry: entry, width: 1, height: 1, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 3
        case 4:
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[0].type)
            page.entries[6] = JournalEntry(entry: entry, width: 2, height: 1, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 6
        case 5:
            page.entries[6] = JournalEntry(entry: page.entries[6], width: 1, height: 1, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[0].type)
            page.entries[7] = JournalEntry(entry: entry, width: 1, height: 1, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 7
        case 6:
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 1, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[0].type)
            page.entries[5] = JournalEntry(entry: entry, width: 1, height: 1, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 5
        default:
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 1, height: 1, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
            page.entries[2] = JournalEntry(entry: entry, width: 1, height: 1, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 2
        }
        page.realEntryCount += 1
        return entrySelection
    }
}
