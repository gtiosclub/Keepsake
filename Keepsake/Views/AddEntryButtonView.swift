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
        VStack {
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
                        
                        if journal.pages[journal.currentPage].entries.count <= 8 {
                            selectedEntry = userVM.newAddJournalEntry(journal: journal, pageNum: displayPage, entry: JournalEntry(date: "", title: "", text: "", summary: "", width: 1, height: 1, isFake: false, color: (0..<3).map { _ in Double.random(in: 0.5...0.99) }))
                        } else {
                            //handle too many entries
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

struct ToastView: View {

    @Binding var isShowing: Bool
    let message: String
    var body: some View {
        ZStack {
            if isShowing {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary)
                    .opacity(0.8)
                    .frame(height: 50)
                    .overlay(alignment: .center) {
                        Text(message)
                            .foregroundColor(.white)
                    }
                    .padding()
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var inTextEntry = false
        @State var displayPage = 2
        @State var selectedEntry = 0
        @ObservedObject var userVM: UserViewModel = UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 2, height: 2, isFake: false, color: [0.55, 0.8, 0.8]), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 1, height: 2, isFake: false, color: [0.5, 0.9, 0.7]), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff", width: 1, height: 2, isFake: false, color: [0.6, 0.7, 0.6]), JournalEntry(), JournalEntry(), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club", width: 2, height: 2, isFake: false, color: [0.9, 0.5, 0.8]), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 2, height: 2, isFake: false, color: [0.5, 0.9, 0.7]), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club", width: 2, height: 2, isFake: false, color: [0.6, 0.55, 0.8]), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .bears), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .stars), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: Texture.green), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ]), JournalShelf(name: "Shelf 2", journals: [
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .red, pageColor: .black, titleColor: .white, texture: .flower1), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ])], scrapbookShelves: []))
        var body: some View {
            AddEntryButtonView(journal: userVM.getJournal(shelfIndex: 0, bookIndex: 0), inTextEntry: $inTextEntry, userVM: userVM, displayPage: $displayPage, selectedEntry: $selectedEntry)
        }
    }

    return Preview()
}
