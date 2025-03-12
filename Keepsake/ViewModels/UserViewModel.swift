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
        if user.savedTemplates.isEmpty {
            user.savedTemplates = [
                Template(name: "Classic", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather),
                Template(name: "Minimalist", coverColor: .gray, pageColor: .white, titleColor: .black, texture: .blackLeather),
                Template(name: "Creative", coverColor: .blue, pageColor: .yellow, titleColor: .white, texture: .flower1),
                Template(name: "Snoopy", coverColor: .black, pageColor: .white, titleColor: .white, texture: .snoopy)
            ]
        }
        self.user = user
    }
    
    func addJournalShelfToUser(_ shelf: JournalShelf) {
        user.addJournalShelf(shelf: shelf)
    }
    
    func getJournalShelves() -> [JournalShelf] {
        return user.journalShelves
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
            page.entries[1] = JournalEntry(entry: page.entries[1], width: 1, height: 1, color: page.entries[1].color, images: page.entries[1].images, type: page.entries[1].type)
            page.entries[3] = JournalEntry(entry: entry, width: 1, height: 1, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 3
        case 4:
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
            page.entries[6] = JournalEntry(entry: entry, width: 2, height: 1, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 6
        case 5:
            page.entries[6] = JournalEntry(entry: page.entries[6], width: 1, height: 1, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
            page.entries[7] = JournalEntry(entry: entry, width: 1, height: 1, color: entry.color, images: entry.images, type: entry.type)
            entrySelection = 7
        case 6:
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 1, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
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
    
    func addJournalToShelf(journal: Journal, shelfIndex: Int) {
        user.journalShelves[shelfIndex].journals.append(journal)
    }
    
    func removeJournalEntry(journal: Journal, pageNum: Int, index: Int) {
        let page = journal.pages[pageNum]
        var entrySelection = 0
        switch page.realEntryCount {
        case 0:
            return
        case 1:
            page.entries[0] = JournalEntry()
        case 2:
            switch index {
            case 0:
                page.entries[0] = page.entries[4]
                page.entries[4] = JournalEntry()
            default:
                page.entries[4] = JournalEntry()
            }
        case 3:
            removeEntryFrom3(page: page, index: index)
        case 4:
            removeEntryFrom4(page: page, index: index)
        case 5:
            removeEntryFrom5(page: page, index: index)
        case 6:
            removeEntryFrom6(page: page, index: index)
        case 7:
            removeEntryFrom7(page: page, index: index)
        default:
            removeEntryFrom8(page: page, index: index)
        }
        page.realEntryCount -= 1
    }
    
    private func removeEntryFrom3(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            page.entries[0] = JournalEntry(entry: page.entries[1], width: 2, height: 2, color: page.entries[1].color, images: page.entries[1].images, type: page.entries[1].type)
            page.entries[1] = JournalEntry()
        case 1:
            page.entries[1] = JournalEntry()
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 2, height: 2, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
        default:
            page.entries[4] = JournalEntry(entry: page.entries[1], width: 2, height: 2, color: page.entries[1].color, images: page.entries[1].images, type: page.entries[1].type)
            page.entries[1] = JournalEntry()
        }
    }
    
    private func removeEntryFrom4(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            page.entries[0] = JournalEntry(entry: page.entries[3], width: 1, height: 2, color: page.entries[3].color, images: page.entries[3].images, type: page.entries[3].type)
            page.entries[1] = JournalEntry(entry: page.entries[1], width: 1, height: 2, color: page.entries[1].color, images: page.entries[1].images, type: page.entries[1].type)
            page.entries[3] = JournalEntry()
        case 1:
            page.entries[1] = JournalEntry(entry: page.entries[3], width: 1, height: 2, color: page.entries[3].color, images: page.entries[3].images, type: page.entries[3].type)
            page.entries[3] = JournalEntry()
        case 3:
            page.entries[1] = JournalEntry(entry: page.entries[1], width: 1, height: 2, color: page.entries[1].color, images: page.entries[1].images, type: page.entries[1].type)
            page.entries[3] = JournalEntry()
        default:
            page.entries[4] = JournalEntry(entry: page.entries[3], width: 2, height: 2, color: page.entries[3].color, images: page.entries[3].images, type: page.entries[3].type)
            page.entries[3] = JournalEntry()
            page.entries[1] = JournalEntry(entry: page.entries[1], width: 1, height: 2, color: page.entries[1].color, images: page.entries[1].images, type: page.entries[1].type)
        }
    }
    
    private func removeEntryFrom5(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            page.entries[0] = JournalEntry(entry: page.entries[6], width: 1, height: 2, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
            page.entries[6] = JournalEntry()
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 2, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
        case 1:
            page.entries[1] = JournalEntry(entry: page.entries[6], width: 1, height: 1, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
            page.entries[6] = JournalEntry()
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 2, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
        case 3:
            page.entries[3] = JournalEntry(entry: page.entries[6], width: 1, height: 1, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
            page.entries[6] = JournalEntry()
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 2, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
        case 4:
            page.entries[4] = JournalEntry(entry: page.entries[6], width: 2, height: 2, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
            page.entries[6] = JournalEntry()
        default:
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 2, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
            page.entries[6] = JournalEntry()
        }
    }
    
    private func removeEntryFrom6(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            page.entries[0] = JournalEntry(entry: page.entries[7], width: 1, height: 2, color: page.entries[7].color, images: page.entries[7].images, type: page.entries[7].type)
            page.entries[6] = JournalEntry(entry: page.entries[6], width: 2, height: 1, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
        case 1:
            page.entries[1] = JournalEntry(entry: page.entries[7], width: 1, height: 1, color: page.entries[7].color, images: page.entries[7].images, type: page.entries[7].type)
            page.entries[6] = JournalEntry(entry: page.entries[6], width: 2, height: 1, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
        case 3:
            page.entries[3] = JournalEntry(entry: page.entries[7], width: 1, height: 1, color: page.entries[7].color, images: page.entries[7].images, type: page.entries[7].type)
            page.entries[6] = JournalEntry(entry: page.entries[6], width: 2, height: 1, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
        case 4:
            page.entries[4] = JournalEntry(entry: page.entries[7], width: 2, height: 1, color: page.entries[7].color, images: page.entries[7].images, type: page.entries[7].type)
            page.entries[6] = JournalEntry(entry: page.entries[6], width: 2, height: 1, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
        case 6:
            page.entries[6] = JournalEntry(entry: page.entries[7], width: 2, height: 1, color: page.entries[7].color, images: page.entries[7].images, type: page.entries[7].type)
        default:
            page.entries[6] = JournalEntry(entry: page.entries[6], width: 2, height: 1, color: page.entries[6].color, images: page.entries[6].images, type: page.entries[6].type)
        }
        page.entries[7] = JournalEntry()
    }
    
    private func removeEntryFrom7(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            page.entries[0] = JournalEntry(entry: page.entries[5], width: 1, height: 2, color: page.entries[5].color, images: page.entries[5].images, type: page.entries[5].type)
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
        case 1:
            page.entries[1] = JournalEntry(entry: page.entries[5], width: 1, height: 1, color: page.entries[5].color, images: page.entries[5].images, type: page.entries[5].type)
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
        case 3:
            page.entries[3] = JournalEntry(entry: page.entries[5], width: 1, height: 1, color: page.entries[5].color, images: page.entries[5].images, type: page.entries[5].type)
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
        case 4:
            page.entries[4] = JournalEntry(entry: page.entries[5], width: 2, height: 1, color: page.entries[5].color, images: page.entries[5].images, type: page.entries[5].type)
        case 5:
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
        case 6:
            page.entries[6] = JournalEntry(entry: page.entries[5], width: 1, height: 1, color: page.entries[5].color, images: page.entries[5].images, type: page.entries[5].type)
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
        default:
            page.entries[7] = JournalEntry(entry: page.entries[5], width: 1, height: 1, color: page.entries[5].color, images: page.entries[5].images, type: page.entries[5].type)
            page.entries[4] = JournalEntry(entry: page.entries[4], width: 2, height: 1, color: page.entries[4].color, images: page.entries[4].images, type: page.entries[4].type)
        }
        page.entries[5] = JournalEntry()
    }
    
    private func removeEntryFrom8(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            page.entries[0] = JournalEntry(entry: page.entries[2], width: 1, height: 2, color: page.entries[2].color, images: page.entries[2].images, type: page.entries[2].type)
        case 1:
            page.entries[1] = JournalEntry(entry: page.entries[2], width: 1, height: 1, color: page.entries[2].color, images: page.entries[2].images, type: page.entries[2].type)
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 1, height: 2, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
        case 2:
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 1, height: 2, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
        case 3:
            page.entries[3] = JournalEntry(entry: page.entries[2], width: 1, height: 1, color: page.entries[2].color, images: page.entries[2].images, type: page.entries[2].type)
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 1, height: 2, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
        case 4:
            page.entries[4] = JournalEntry(entry: page.entries[2], width: 1, height: 1, color: page.entries[2].color, images: page.entries[2].images, type: page.entries[2].type)
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 1, height: 2, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
        case 5:
            page.entries[5] = JournalEntry(entry: page.entries[2], width: 1, height: 1, color: page.entries[2].color, images: page.entries[2].images, type: page.entries[2].type)
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 1, height: 2, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
        case 6:
            page.entries[6] = JournalEntry(entry: page.entries[2], width: 1, height: 1, color: page.entries[2].color, images: page.entries[2].images, type: page.entries[2].type)
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 1, height: 2, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
        default:
            page.entries[7] = JournalEntry(entry: page.entries[2], width: 1, height: 1, color: page.entries[2].color, images: page.entries[2].images, type: page.entries[2].type)
            page.entries[0] = JournalEntry(entry: page.entries[0], width: 1, height: 2, color: page.entries[0].color, images: page.entries[0].images, type: page.entries[0].type)
        }
        page.entries[2] = JournalEntry()
    }
}
