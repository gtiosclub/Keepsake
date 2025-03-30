//
//  BookshelfView.swift
//  Keepsake
//
//  Created by Connor on 2/12/25.
//

import SwiftUI


struct BookshelfView: View {
    @ObservedObject var shelf: JournalShelf
    @State var scale: CGFloat = 0.24
    @State var isEditing: Bool = false
    @State var editedName: String = ""
    @ObservedObject var fbVM: FirebaseViewModel
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isEditing {
                    TextField("Enter name", text: $editedName, onCommit: {
                        shelf.name = editedName
                        isEditing = false
                        Task {
                            await fbVM.updateShelfName(shelfID: shelf.id, newName: editedName)
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 150)
                } else {
                    Text(shelf.name)
                        .font(.headline)
                }
                
                Button(action: {
                    isEditing.toggle()
                    if isEditing {
                        editedName = shelf.name
                    }
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                if !shelf.journals.isEmpty {
                    // Placeholder to maintain height and width
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.2))
//                        .frame(height: 100)
//                        .cornerRadius(8)
//                        .padding(.horizontal)
//                        .padding(.vertical)
                    ForEach(shelf.journals.indices, id: \.self) { index in
                        JournalSpine(book: shelf.journals[index], degrees: 0)
                            .scaleEffect(scale)
                            .frame(width: scale * UIScreen.main.bounds.width * 0.4, height: scale * UIScreen.main.bounds.height * 0.56)
                    }
                }
//                else {
//                    ForEach(shelf.books.indices, id: \.self) { _ in
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.3))
//                            .frame(height: 100)
//                            .cornerRadius(8)
//                            .padding(.horizontal)
//                            .padding(.vertical)
//                    }
//                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color.white)
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    BookshelfView(shelf: JournalShelf(name: "Bookshelf", journals: [
        Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
        Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
    ]), fbVM: FirebaseViewModel())
}
