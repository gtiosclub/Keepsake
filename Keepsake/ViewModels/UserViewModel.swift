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
    
    func newAddJournalEntry(shelfIndex: Int, bookIndex: Int, pageNum: Int, entry: JournalEntry) {
        var page = user.getJournalShelves()[shelfIndex].journals[bookIndex].pages[pageNum]
        var entries = page.entries
        switch page.realEntryCount {
        case 0:
            entries[0] = JournalEntry(entry: entry, width: 2, height: 2, color: entry.color)
        case 1:
            entries[4] = JournalEntry(entry: entry, width: 2, height: 2, color: entry.color)
        case 2:
            entries[0] = JournalEntry(entry: entries[0], width: 1, height: 2, color: entries[0].color)
            entries[1] = JournalEntry(entry: entry, width: 1, height: 2, color: entry.color)
        case 3:
            entries[1] = JournalEntry(entry: entries[2], width: 1, height: 1, color: entries[0].color)
            entries[3] = JournalEntry(entry: entry, width: 1, height: 1, color: entry.color)
        case 4:
            entries[4] = JournalEntry(entry: entries[4], width: 2, height: 1, color: entries[4].color)
            entries[6] = JournalEntry(entry: entry, width: 2, height: 1, color: entry.color)
        case 5:
            entries[6] = JournalEntry(entry: entries[6], width: 1, height: 1, color: entries[6].color)
            entries[7] = JournalEntry(entry: entry, width: 1, height: 1, color: entry.color)
        case 6:
            entries[4] = JournalEntry(entry: entries[4], width: 1, height: 1, color: entries[4].color)
            entries[5] = JournalEntry(entry: entry, width: 1, height: 1, color: entry.color)
        default:
            entries[0] = JournalEntry(entry: entries[0], width: 1, height: 1, color: entries[0].color)
            entries[2] = JournalEntry(entry: entry, width: 1, height: 1, color: entries[0].color)
        }
        page.realEntryCount += 1
    }
}
