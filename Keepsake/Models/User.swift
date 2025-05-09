//
//  User.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation
import SwiftUI
import PhotosUI


typealias UserInfo = (userID: String, name: String,username: String, profilePic: UIImage?, friends: [String])
typealias UserInfoWithStreaks = (userID: String, name: String,username: String, profilePic: UIImage?, friends: [String], streakCount: Int?)

class User: Identifiable, ObservableObject {
    var id: String
    var name: String
    var username: String
    @Published var journalShelves: [JournalShelf]
    @Published var scrapbookShelves: [ScrapbookShelf]
    @Published var savedTemplates: [Template]
    var lastUsedJShelfID: UUID
    var lastUsedSShelfID: UUID
    var isJournalLastUsed: Bool
    @Published var journalShelfIndex: Int = 0
    @Published var scrapbookShelfIndex: Int = 0
    @Published var friends: [String]
    @Published var images: [String:UIImage] = [:]
    @Published var streaks: Int = 0
    @Published var lastJournaled: TimeInterval?
    @Published var communityScrapbooks: [Scrapbook : [UserInfo]] = [:]
    @Published var savedScrapbooks: [Scrapbook] = []
    
    init(id: String, name: String, username: String, journalShelves: [JournalShelf], scrapbookShelves: [ScrapbookShelf], savedTemplates: [Template] = [], friends: [String], lastUsedJShelfID: UUID, lastUsedSShelfID: UUID, isJournalLastUsed: Bool, images: [String: UIImage] = [:], communityScrapbooks: [Scrapbook : [UserInfo]] = [:], savedScrapbooks: [Scrapbook] = []) {
        self.id = id
        self.name = name
        self.username = username
        self.journalShelves = journalShelves
        self.scrapbookShelves = scrapbookShelves
        self.savedTemplates = savedTemplates
        self.isJournalLastUsed = true
        self.friends = friends
        self.lastUsedJShelfID = lastUsedJShelfID
        self.lastUsedSShelfID = lastUsedSShelfID
        self.isJournalLastUsed = isJournalLastUsed
        self.images = images
        self.communityScrapbooks = communityScrapbooks
        self.savedScrapbooks = savedScrapbooks
    }
    init(id: String, name: String, username: String, journalShelves: [JournalShelf], scrapbookShelves: [ScrapbookShelf], savedTemplates: [Template] = [], friends: [String]) {
        self.id = id
        self.name = name
        self.username = username
        self.journalShelves = journalShelves
        self.scrapbookShelves = scrapbookShelves
        self.savedTemplates = savedTemplates
        self.isJournalLastUsed = true
        self.friends = friends
        self.lastUsedJShelfID = UUID()
        self.lastUsedSShelfID = UUID()
        self.isJournalLastUsed = true
    }
    init(id: String, name: String, journalShelves: [JournalShelf], scrapbookShelves: [ScrapbookShelf], savedTemplates: [Template] = []) {
        self.id = id
        self.name = name
        self.username = name + "@gmail.com"
        self.journalShelves = journalShelves
        self.scrapbookShelves = scrapbookShelves
        self.savedTemplates = savedTemplates
        self.friends = []
        self.lastUsedJShelfID = UUID()
        self.lastUsedSShelfID = UUID()
        self.isJournalLastUsed = true
    }
    
    // Provide default values for id and name
    init(journalShelves: [JournalShelf] = [], scrapbookShelves: [ScrapbookShelf] = [], savedTemplates: [Template] = []) {
        self.id = UUID().uuidString
        self.name = "Default User"
        self.username = "default@gmail.com"
        self.journalShelves = journalShelves
        self.scrapbookShelves = scrapbookShelves
        self.savedTemplates = []
        self.lastUsedJShelfID = UUID()
        self.lastUsedSShelfID = UUID()
        self.isJournalLastUsed = true
        self.friends = []

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
