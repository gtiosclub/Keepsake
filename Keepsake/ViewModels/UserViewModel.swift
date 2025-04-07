//
//  UserViewModel.swift
//  Keepsake
//
//  Created by Alec Hance on 2/28/25.
//

import Foundation
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var user: User
    
    init(user: User) {
        if user.savedTemplates.isEmpty {
            user.savedTemplates = [
                Template(name: "Classic", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather, journalPages: [
                    JournalPage(number: 1),
                    JournalPage(number: 2,
                                entries: [
                                    WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")],
                                realEntryCount: 1),
                    JournalPage(number: 3,
                                entries: [
                                    WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"),
                                    WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"),
                                    WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")],
                                realEntryCount: 3),
                    JournalPage(number: 4,
                                entries: [
                                    WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"),
                                    WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")],
                                realEntryCount: 2),
                    JournalPage(number: 5)]),
                Template(name: "Minimalist", coverColor: .gray, pageColor: .white, titleColor: .black, texture: .blackLeather, journalPages: [JournalPage(
                    number: 1,
                    entries: [WrittenEntry(date: "2025-03-26",title: "Entry 1",text: "Sample text for entry 1",summary: "Summary of entry 1"),
                              WrittenEntry(date: "2025-03-26",title: "Entry 2",text: "Sample text for entry 2",summary: "Summary of entry 2"),
                              WrittenEntry(date: "2025-03-26",title: "Entry 8",text: "Sample text for entry 8",summary: "Summary of entry 8")],
                    realEntryCount: 0
                )]),
                Template(name: "Creative", coverColor: .blue, pageColor: .yellow, titleColor: .white, texture: .flower1),
                Template(name: "Snoopy", coverColor: .black, pageColor: .white, titleColor: .white, texture: .snoopy)
            ]
        }
        self.user = user
    }
    
    func addJournalShelfToUser(_ shelf: JournalShelf) {
        user.addJournalShelf(shelf: shelf)
    }
    
    func removeJournaShelf(index: Int) {
        user.journalShelves.remove(at: index)
    }
    
    func addScrapbookShelfToUser(_ shelf: ScrapbookShelf) {
        user.addScrapbookShelf(shelf: shelf)
    }
    
    func getJournalShelves() -> [JournalShelf] {
        return user.journalShelves
    }
    
    func getJournal(shelfIndex: Int, bookIndex: Int) -> Journal {
        return user.getJournalShelves()[shelfIndex].journals[bookIndex]
    }
    
    
    func getScrapbook(shelfIndex: Int, bookIndex: Int) -> Scrapbook {
        return user.getScrapbookShelves()[shelfIndex].scrapbooks[bookIndex]
    }
    
    
    func getJournalIndex(journal: Journal, shelfIndex: Int) -> Int {
        var journals = getJournalShelves()[shelfIndex].journals
        for index in journals.indices {
            if journals[index].id == journal.id {
                return index
            }
        }
        return 0
    }
    
    func deletePage(journal: Journal, pageNumber: Int) {
        guard let index = journal.pages.firstIndex(where: { $0.number == pageNumber }) else {
            print("Page \(pageNumber) not found")
            return
        }
        journal.pages.remove(at: index)
        for page in journal.pages {
            if page.number > pageNumber {
                page.number = page.number - 1
            }
        }
//        let favoritePagesIndex = journal.favoritePages.firstIndex(of: pageNumber) ?? -1
//        if favoritePagesIndex >= 0 {
//            journal.favoritePages.remove(at: favoritePagesIndex)
//        }
//        journal.favoritePages = journal.favoritePages.map { num in
//            if num > pageNumber {
//                return num - 1
//            } else {
//                return num
//            }
//        }
//        print(journal.favoritePages)
        
    }
    
    func getJournalEntry(shelfIndex: Int, bookIndex: Int, pageNum: Int, entryIndex: Int) -> JournalEntry {
        return user.getJournalShelves()[shelfIndex].journals[bookIndex].pages[pageNum].entries[entryIndex]
    }
    
    func updateJournalEntry(shelfIndex: Int, bookIndex: Int, pageNum: Int, entryIndex: Int, newEntry: JournalEntry) {
        print(newEntry.width, newEntry.height, newEntry.id)
        user.getJournalShelves()[shelfIndex].journals[bookIndex].pages[pageNum].entries[entryIndex] = newEntry
    }
    
    func updateJournalEntry(journal: Journal, pageNum: Int, entryIndex: Int, newEntry: JournalEntry) {
        journal.pages[pageNum].entries[entryIndex] = newEntry
    }
    
    func updateScrapbookEntry(scrapbook: Scrapbook, pageNum: Int, newEntry: ScrapbookEntry) {
        scrapbook.pages[pageNum].entries.append(newEntry)
    }
    func clearScrapbookPage(scrapbook: Scrapbook, pageNum: Int) {
        scrapbook.pages[pageNum].entries = []
    }
    
    func getShelfIndex() -> Int {
        return user.shelfIndex
    }
    
    func getImage(url: String) -> UIImage? {
        return user.images[url]
    }
    
    func addImageToUser(url: String, image: UIImage) {
        user.images[url] = image
    }
    
    func setShelfIndex(index: Int, shelfID: UUID, isJournal: Bool) -> Void {
        user.shelfIndex = index
        user.lastUsedShelfID = shelfID
        user.isJournalLastUsed = isJournal
    }
    
    func setShelfToLastUsedJShelf() {
        let shelves = user.getJournalShelves()
        for index in shelves.indices {
            if shelves[index].id == user.lastUsedShelfID {
                user.shelfIndex = index
            }
        }
    }
    
    func newAddJournalEntry(journal: Journal, pageNum: Int, entry: JournalEntry) -> Int {
        let page = journal.pages[pageNum]
        var entrySelection = 0
        switch page.realEntryCount {
        case 0:
            typeSafeEntryHelper(page: page, lhs: 0, entry: entry, width: 2, height: 2)
            entrySelection = 0
        case 1:
            typeSafeEntryHelper(page: page, lhs: 4, entry: entry, width: 2, height: 2)
            entrySelection = 4
        case 2:
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 1, height: 2)
            typeSafeEntryHelper(page: page, lhs: 1, entry: entry, width: 1, height: 2)
            entrySelection = 1
        case 3:
            typeSafeEntryHelper(page: page, lhs: 1, rhs: 1, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 3, entry: entry, width: 1, height: 1)
            entrySelection = 3
        case 4:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 1)
            typeSafeEntryHelper(page: page, lhs: 6, entry: entry, width: 2, height: 1)
            entrySelection = 6
        case 5:
            typeSafeEntryHelper(page: page, lhs: 6, rhs: 6, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 7, entry: entry, width: 1, height: 1)
            entrySelection = 7
        case 6:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 5, entry: entry, width: 1, height: 1)
            entrySelection = 5
        default:
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 2, entry: entry, width: 1, height: 1)
            entrySelection = 2
        }
        page.realEntryCount += 1
        return entrySelection
    }
    
    func addJournalToShelf(journal: Journal, shelfIndex: Int) {
//        user.journalShelves[shelfIndex].journals.append(journal)
        user.getJournalShelves()[shelfIndex].journals.append(journal)
    }
    
    func removeJournalFromShelf(shelfIndex: Int, journalID: UUID) {
        let journals = user.getJournalShelves()[shelfIndex].journals
        for index in journals.indices {
            if journalID == journals[index].id {
                user.getJournalShelves()[shelfIndex].journals.remove(at: index)
                return
            }
        }
    }
    
    func addPage(page: JournalPage, journal: Journal) {
        journal.pages.append(JournalPage(number: journal.pages.count + 1, page: page))
    }
    
    func addJournalToShelfAndAddEntries(journal: Journal, shelfIndex: Int) {
        user.getJournalShelves()[shelfIndex].journals.append(journal)
        
        if !journal.pages.isEmpty {
            for pageIndex in journal.pages.indices {
                let page = journal.pages[pageIndex]
//                let originalEntries = page.entries.filter { !$0.date.isEmpty || !$0.title.isEmpty || !$0.text.isEmpty }
                let originalEntries = page.entries.filter { !$0.isFake }
                // Only reset and process if there are non-empty entries
                if !originalEntries.isEmpty {
                    let fakeEntry = JournalEntry(date: "", title: "", entryContents: "", type: .written)
                    page.entries = Array(repeating: fakeEntry, count: 8)
                    page.realEntryCount = 0
                    
                    for entry in originalEntries {
                        _ = newAddJournalEntry(journal: journal, pageNum: pageIndex, entry: entry)
                    }
                }
            }
        }
    }
    
    func removeJournalEntry(page: JournalPage, index: Int) {
        for entry in page.entries {
            print(entry.width, entry.height, entry.title, entry.id, entry.isFake)
        }
        print()
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
        for entry in page.entries {
            print(entry.width, entry.height, entry.title, entry.id, entry.isFake)
        }
    }
    
    private func typeSafeEntryHelper(page: JournalPage, lhs: Int, rhs: Int, width: Int, height: Int) {
        if let writtenEntry = page.entries[rhs] as? WrittenEntry {
            // Now you can use WrittenEntry-specific properties
            page.entries[lhs] = JournalEntry.create(from: writtenEntry, width: width, height: height)
        } else if let chatEntry = page.entries[rhs] as? ConversationEntry {
            page.entries[lhs] = JournalEntry.create(from: chatEntry, width: width, height: height)
        } else if let pictureEntry = page.entries[rhs] as? PictureEntry {
            page.entries[lhs] = JournalEntry.create(from: pictureEntry, width: width, height: height)
        } else if let voiceEntry = page.entries[rhs] as? VoiceEntry {
            page.entries[lhs] = JournalEntry.create(from: voiceEntry, width: width, height: height)
        }
    }
    
    private func typeSafeEntryHelper(page: JournalPage, lhs: Int, entry: JournalEntry, width: Int, height: Int) {
        if let writtenEntry = entry as? WrittenEntry {
            // Now you can use WrittenEntry-specific properties
            page.entries[lhs] = JournalEntry.create(from: writtenEntry, width: width, height: height)
        } else if let chatEntry = entry as? ConversationEntry {
            page.entries[lhs] = JournalEntry.create(from: chatEntry, width: width, height: height)
        } else if let pictureEntry = entry as? PictureEntry {
            page.entries[lhs] = JournalEntry.create(from: pictureEntry, width: width, height: height)
        } else if let voiceEntry = entry as? VoiceEntry {
            page.entries[lhs] = JournalEntry.create(from: voiceEntry, width: width, height: height)
        }
    }
    
    private func removeEntryFrom3(page: JournalPage, index: Int) {
        print("enter 3")
        switch(index) {
        case 0:
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 1, width: 2, height: 2)
            page.entries[1] = JournalEntry()
        case 1:
            page.entries[1] = JournalEntry()
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 2, height: 2)
        default:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 1, width: 2, height: 2)
            page.entries[1] = JournalEntry()
        }
    }
    
    private func removeEntryFrom4(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 3, width: 1, height: 2)
            typeSafeEntryHelper(page: page, lhs: 1, rhs: 1, width: 1, height: 2)
            page.entries[3] = JournalEntry()
        case 1:
            typeSafeEntryHelper(page: page, lhs: 1, rhs: 3, width: 1, height: 2)
            page.entries[3] = JournalEntry()
        case 3:
            typeSafeEntryHelper(page: page, lhs: 1, rhs: 1, width: 1, height: 2)
            page.entries[3] = JournalEntry()
        default:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 3, width: 2, height: 2)
            page.entries[3] = JournalEntry()
            typeSafeEntryHelper(page: page, lhs: 1, rhs: 1, width: 1, height: 2)
        }
    }
    
    private func removeEntryFrom5(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 6, width: 1, height: 2)
            page.entries[6] = JournalEntry()
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 2)
        case 1:
            typeSafeEntryHelper(page: page, lhs: 1, rhs: 6, width: 1, height: 1)
            page.entries[6] = JournalEntry()
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 2)
        case 3:
            typeSafeEntryHelper(page: page, lhs: 3, rhs: 6, width: 1, height: 1)
            page.entries[6] = JournalEntry()
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 2)
        case 4:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 6, width: 2, height: 2)
            page.entries[6] = JournalEntry()
        default:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 2)
            page.entries[6] = JournalEntry()
        }
    }
    
    private func removeEntryFrom6(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 7, width: 1, height: 2)
            typeSafeEntryHelper(page: page, lhs: 6, rhs: 6, width: 2, height: 1)
        case 1:
            typeSafeEntryHelper(page: page, lhs: 1, rhs: 7, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 6, rhs: 6, width: 2, height: 1)
        case 3:
            typeSafeEntryHelper(page: page, lhs: 3, rhs: 7, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 6, rhs: 6, width: 2, height: 1)
        case 4:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 7, width: 2, height: 1)
            typeSafeEntryHelper(page: page, lhs: 6, rhs: 6, width: 2, height: 1)
        case 6:
            typeSafeEntryHelper(page: page, lhs: 6, rhs: 7, width: 2, height: 1)
        default:
            typeSafeEntryHelper(page: page, lhs: 6, rhs: 6, width: 2, height: 1)
        }
        page.entries[7] = JournalEntry()
    }
    
    private func removeEntryFrom7(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 5, width: 1, height: 2)
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 1)
        case 1:
            typeSafeEntryHelper(page: page, lhs: 1, rhs: 5, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 1)
        case 3:
            typeSafeEntryHelper(page: page, lhs: 3, rhs: 5, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 1)
        case 4:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 5, width: 2, height: 1)
        case 5:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 1)
        case 6:
            typeSafeEntryHelper(page: page, lhs: 6, rhs: 5, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 1)
        default:
            typeSafeEntryHelper(page: page, lhs: 7, rhs: 5, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 4, width: 2, height: 1)
        }
        page.entries[5] = JournalEntry()
    }
    
    private func removeEntryFrom8(page: JournalPage, index: Int) {
        switch(index) {
        case 0:
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 2, width: 1, height: 2)
        case 1:
            typeSafeEntryHelper(page: page, lhs: 1, rhs: 2, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 1, height: 2)
        case 2:
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 1, height: 2)
        case 3:
            typeSafeEntryHelper(page: page, lhs: 3, rhs: 2, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 1, height: 2)
        case 4:
            typeSafeEntryHelper(page: page, lhs: 4, rhs: 2, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 1, height: 2)
        case 5:
            typeSafeEntryHelper(page: page, lhs: 5, rhs: 2, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 1, height: 2)
        case 6:
            typeSafeEntryHelper(page: page, lhs: 6, rhs: 2, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 1, height: 2)
        default:
            typeSafeEntryHelper(page: page, lhs: 7, rhs: 2, width: 1, height: 1)
            typeSafeEntryHelper(page: page, lhs: 0, rhs: 0, width: 1, height: 2)
        }
        page.entries[2] = JournalEntry()
    }
}
