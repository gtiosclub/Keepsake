//
//  ContentView.swift
//  Keepsake
//
//  Created by Rik Roy on 2/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                LibraryView(user: User(id: "123", name: "Steve", shelves: [Shelf(name: "Bookshelf", books: [
                    Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                    Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                    Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                    Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])])
                ]), Shelf(name: "Shelf 2", books: [])]))
            }


            Tab("Community", systemImage: "person.2") {
                CommunityView()
            }
        }.onAppear {
            // correct the transparency bug for Tab bars
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            // correct the transparency bug for Navigation bars
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
    }
}

#Preview {
    ContentView()
}
