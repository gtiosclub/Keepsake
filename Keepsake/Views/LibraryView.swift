//
//  LibraryView.swift
//  Keepsake
//
//  Created by Connor on 2/12/25.
//


import SwiftUI

struct LibraryView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    @State private var showBookshelfView = true

    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $showBookshelfView) {
                    Text("Bookshelves").tag(true)
                    Text("Scrapbooks").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if showBookshelfView {
                    LibraryBookshelfView(userVM: userVM, aiVM: aiVM)
                } else {
                    LibraryScrapbookView(userVM: userVM, aiVM: aiVM) // Add Scrapbook View
                }
            }
        }
    }
}

struct LibraryBookshelfView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(userVM.user.getJournalShelves().indices, id: \.self) { index in
                    NavigationLink(destination: ShelfView(userVM: userVM, aiVM: aiVM, shelfIndex: index)) {
                        BookshelfView(shelf: userVM.user.getJournalShelves()[index])
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Your Journals")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    userVM.addJournalShelfToUser(JournalShelf(name: "new", journals: []))
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
}

struct LibraryScrapbookView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(userVM.user.getScrapbookShelves().indices, id: \.self) { index in
                    NavigationLink(destination: ShelfView(userVM: userVM, aiVM: aiVM, shelfIndex: index)) {
                        BookshelfForScrapbookView(shelf: userVM.user.getScrapbookShelves()[index])
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Your Scrapbooks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
//                    userVM.addScrapbookShelfToUser(JournalShelf(name: "new", journals: []))
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
}
    
    
    
    
    
    
    
    

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUser = User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [
            ScrapbookShelf(name: "Travel Memories", scrapbooks: [
                Scrapbook(
                    name: "Paris Trip",
                    createdDate: "1/15/25",
                    entries: [
                        ScrapbookEntry(id: "1", imageURL: "", caption: "Eiffel Tower at sunset", date: "1/16/25"),
                        ScrapbookEntry(id: "2", imageURL: "", caption: "Best croissant ever!", date: "1/17/25"),
                        ScrapbookEntry(id: "3", imageURL: "", caption: "Louvre visit", date: "1/18/25")
                    ],
                    category: "Travel",
                    isSaved: true,
                    isShared: false,
                    template: Template(name: "Elegant", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather)
                ),
                Scrapbook(
                    name: "Summer Road Trip",
                    createdDate: "7/5/24",
                    entries: [
                        ScrapbookEntry(id: "4", imageURL: "", caption: "Grand Canyon view", date: "7/6/24"),
                        ScrapbookEntry(id: "5", imageURL: "", caption: "Campfire with friends", date: "7/7/24")
                    ],
                    category: "Adventure",
                    isSaved: false,
                    isShared: true,
                    template: Template(coverColor: .green, pageColor: .white, titleColor: .black)
                )
            ])
        ])
        
        return LibraryView(userVM: UserViewModel(user: sampleUser), aiVM: AIViewModel())
    }
}

