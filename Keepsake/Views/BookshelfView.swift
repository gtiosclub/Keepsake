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
    let angles: [Double] = [0, 0, -2, -10, -30]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .frame(height: 150)
                .cornerRadius(10)
                .shadow(radius: 2)

            HStack(alignment: .bottom) {
                HStack(spacing: 2) { // Align spines to the left
                    ForEach(shelf.journals.indices, id: \.self) { index in
                        let angle = angles[index % angles.count]
                        let spacing = abs(angle) * 0.8 // Increase spacing for larger angles

                        JournalSpine(book: shelf.journals[index], degrees: angle)
                            .scaleEffect(scale)
                            .rotationEffect(.degrees(angle))
                            .offset(x: spacing, y: 0) // Adjust offset based on angle
                            .frame(width: scale * UIScreen.main.bounds.width * 0.4, height: scale * UIScreen.main.bounds.height * 0.56)
                            .alignmentGuide(.bottom) { _ in 0 } // Ensure all spines align at the bottom
                    }
                }
                .padding(.leading, 4)

                Spacer()

                VStack(alignment: .trailing) {
                    Text(shelf.name)
                        .font(.headline)
                        .padding(.trailing, 20)
                        .padding(.top, -20)
                    
                    Spacer()
                }
            }
            .padding(.bottom, 2)
            .frame(height: 120)
        }
        .frame(height: 150)
    }
}

#Preview {
    BookshelfView(shelf: JournalShelf(name: "Bookshelf", journals: [
        Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
        Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
    ]))
}
