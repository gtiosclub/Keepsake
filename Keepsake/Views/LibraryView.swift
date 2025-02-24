//
//  LibraryView.swift
//  Keepsake
//
//  Created by Connor on 2/12/25.
//


import SwiftUI

struct LibraryView: View {
    @ObservedObject var user: User
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(user.shelves.indices, id: \.self) { index in
                        NavigationLink(destination: HomepageView(shelf: user.shelves[index])) {
                            BookshelfView(shelf: user.shelves[index])
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Your Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { /* Add bookshelf action */ }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUser = User(id: "1", name: "Sample User", shelves: [
            Shelf(name: "2025", books: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: Color(red: 0.9, green: 0.9, blue: 0.9), titleColor: .black), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Template 2", coverColor: .green, pageColor: .white, titleColor: .black), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])])
            ]),
            Shelf(name: "2024", books: [Scrapbook(name: "Scrapbook B", createdDate: "2022-06-15", entries: [], category: "Travel", isSaved: true, isShared: true, template: Template())])
        ])
        
        return LibraryView(user: sampleUser)
    }
}

