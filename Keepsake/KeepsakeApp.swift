//
//  KeepsakeApp.swift
//  Keepsake
//
//  Created by Rik Roy on 2/2/25.
//

import SwiftUI

import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct KeepsakeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebaseViewModel = FirebaseViewModel.vm
    @StateObject private var authViewModel = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", id: UUID(), journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 2, height: 2, isFake: false, color: [0.55, 0.8, 0.8]), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 1, height: 2, isFake: false, color: [0.5, 0.9, 0.7]), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff", width: 1, height: 2, isFake: false, color: [0.6, 0.7, 0.6]), JournalEntry(), JournalEntry(), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club", width: 2, height: 2, isFake: false, color: [0.9, 0.5, 0.8]), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 2, height: 2, isFake: false, color: [0.5, 0.9, 0.7]), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club", width: 2, height: 2, isFake: false, color: [0.6, 0.55, 0.8]), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .bears), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .stars), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: Texture.green), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ]), JournalShelf(name: "Shelf 2", id: UUID(), journals: [
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .red, pageColor: .black, titleColor: .white, texture: .flower1), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ])], scrapbookShelves: [])), aiVM: AIViewModel())
//                .environmentObject(authViewModel)
//                .environmentObject(firebaseViewModel)
        }
    }
}
