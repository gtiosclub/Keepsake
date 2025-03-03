//
//  AddEntryButtonView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/26/25.
//

import SwiftUI

struct AddEntryButtonView: View {
    @State var isExpanded: Bool = false
    @ObservedObject var journal: Journal
    @Binding var inTextEntry: Bool
    @ObservedObject var userVM: UserViewModel
    @Binding var displayPage: Int
    @Binding var selectedEntry: Int
    var body: some View {
        HStack {
            if !isExpanded {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.red)

                }
            }
            if isExpanded {
                HStack {
                    Button(action: {
                        
                        if journal.pages[journal.currentPage].entries.count >= 3 {
                            journal.currentPage += 1
                            displayPage = journal.currentPage
                            selectedEntry = 0
                            journal.pages[journal.currentPage].entries.append(JournalEntry(date: "01-01-2020", title: "", text: "", summary: ""))
                        } else {
                            displayPage = journal.currentPage
                            journal.pages[journal.currentPage].entries.append(JournalEntry(date: "01-01-2020", title: "", text: "", summary: ""))
                            selectedEntry = journal.pages[journal.currentPage].entries.count - 1
                        }
                        withTransaction(Transaction(animation: .none)) {
                            inTextEntry.toggle()
                        }
                    }) { Image(systemName: "t.square.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                        .foregroundColor(.black)}
                    Button(action: {}) {Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                        .foregroundColor(.blue)}
                    Button(action:{}) {Image(systemName: "face.smiling.inverse")
                            .resizable()
                            .frame(width: 45, height: 45)
                        .foregroundColor(.yellow)}
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                                        isExpanded.toggle()
                                    }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                        .foregroundColor(.red)}
                }.transition(.move(edge: .trailing).combined(with: .opacity))
                .padding(.trailing, 10)
            }
        }
    }
}

//#Preview {
//    struct Preview: View {
//        @State var inTextEntry = false
//        @ObservedObject var userVM: UserViewModel = UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
//            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")]), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")]), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")]), JournalPage(number: 5, entries: [])], currentPage: 3),
//            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])], currentPage: 0),
//            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])], currentPage: 0),
//            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])], currentPage: 0)
//        ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: []))
//        var body: some View {
//            AddEntryButtonView(journal: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")]), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")]), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")]), JournalPage(number: 5, entries: [])], currentPage: 3), inTextEntry: $inTextEntry, userVM: userVM)
//        }
//    }
//
//    return Preview()
//}
