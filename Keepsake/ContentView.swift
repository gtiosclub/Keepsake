//
//  ContentView.swift
//  Keepsake
//
//  Created by Rik Roy on 2/2/25.
//

import SwiftUI
enum TabType: Hashable {
    case home
    case community
    case profile
}
struct ContentView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    @EnvironmentObject var reminderViewModel: RemindersViewModel

    @State var selectedTab: TabType = .home

    @State var image: UIImage?
    

    var body: some View {
        
            
            
            NavigationView {

                
                TabView(selection: $selectedTab) {
                    HomeView(userVM: userVM, aiVM: aiVM, fbVM: fbVM, selectedOption: .journal_shelf)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(TabType.home)

                    CommunityView()
                        .tabItem {
                            Label("Community", systemImage: "person.2")
                        }
                        .tag(TabType.community)

                    ProfileView(retrievedImage: fbVM.retrievedImage)
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag(TabType.profile)

              
                }
                .onAppear() {
                    Task {
                        image = await fbVM.getProfilePic(uid: userVM.user.id)
                        await fbVM.checkIfStreaksRestarted()
                    }
                        if let uid = fbVM.currentUser?.id {
                            fbVM.scheduleReminderNotifications(for: uid)
                        }
                }
                
            }
        }
    
}

#Preview {
    ContentView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
        Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
        Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
    ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [], savedTemplates: [])), aiVM: AIViewModel(), fbVM: FirebaseViewModel())
}
