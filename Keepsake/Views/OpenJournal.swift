//
//  Open Journal.swift
//  Keepsake
//
//  Created by Alec Hance on 2/11/25.
//

import SwiftUI

struct OpenJournal: View {
    @Namespace private var openJournalNamespace
//    @State var book: any Book
    @ObservedObject var userVM: UserViewModel
    @State var shelfIndex: Int
    @State var bookIndex: Int
    @Binding var degrees: CGFloat
    @Binding var isHidden: Bool
    @Binding var show: Bool
    @State var displayDegrees: CGFloat = 0
    @Binding var frontDegrees: CGFloat
    @State var zIndex: Double = -1
    @Binding var circleStart: CGFloat
    @Binding var circleEnd: CGFloat
    @Binding var displayPageIndex: Int
    @State var displayIsHidden: Bool = false
    @State var frontIsHidden: Bool = true
    @Binding var coverZ: Double
    @Binding var scaleFactor: CGFloat
    @Binding var inTextEntry: Bool
    @State var entryIndex = -1
    @State var scaleFactor2 = 0
    @Binding var selectedEntry: Int
    var body: some View {
        ZStack {
            JournalBackPagesView(book: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex), displayPageIndex: $displayPageIndex, degrees: $degrees)
            JournalDisplayView(displayIsHidden: $displayIsHidden, userVM: userVM, shelfIndex: shelfIndex, bookIndex: bookIndex, displayPageIndex: $displayPageIndex, zIndex: $zIndex, displayDegrees: $displayDegrees, circleStart: $circleStart, circleEnd: $circleEnd, frontIsHidden: $frontIsHidden, frontDegrees: $frontDegrees, inTextEntry: $inTextEntry, selectedEntry: $selectedEntry)
            
            JournalFrontPagesView(book: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex), degrees: $degrees, frontIsHidden: $frontIsHidden, displayPageIndex: $displayPageIndex, frontDegrees: $frontDegrees, isHidden: $isHidden, coverZ: $coverZ)
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .trim(from: circleStart, to: circleEnd)
                                .stroke(lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.08)
                                .opacity(isHidden ? 1 : 0)
                            
                        }.frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.04)
                        
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.45)
            HStack {
                Button(action: {
                    circleStart = 0.5
                    circleEnd = 1
                    withAnimation(.linear(duration: 1).delay(0.5)) {
                        circleStart += 0.25
                        degrees += 90
                        frontDegrees += 90
                    } completion: {
                        coverZ = 0
                        isHidden = false
                        withAnimation {
                            circleStart += 0.25
                            degrees += 90
                            frontDegrees += 90
                        } completion: {
                            withAnimation(.linear(duration: 0.7)) {
                                scaleFactor = 0.6
                            } completion: {
                                withAnimation {
                                    show.toggle()
                                }
                            }
                        }
                    }
                }, label: {
                    Image(systemName: "return")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.1)
                }).opacity(degrees == -180 ? 1 : 0)
                Spacer()
                AddEntryButtonView()
                    .opacity(degrees == -180 ? 1 : 0)
            }.padding(.horizontal, 20).offset(y: UIScreen.main.bounds.height * 0.33)
        }
 
    }
}
//
//#Preview {
//    OpenJournal(book: shelf.books[number], degrees: $degrees)
//}

#Preview {
    struct Preview: View {
        @State var degrees: CGFloat = -180
        @State var frontDegrees: CGFloat = -180
        @State var show: Bool = true
        @State var cover: Double = -2
        @State var circleStart: CGFloat = 0.5
        @State var circleEnd: CGFloat = 1
        @State var scaleFactor: CGFloat = 0.6
        @State var isHidden: Bool = true
        @State var mainCircleStart: CGFloat = 0.5
        @State var inTextEntry = false
        @State var selectedEntry: Int = 0
        @State var displayPageIndex: Int = 2
        var body: some View {
            OpenJournal(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")]), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")]), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")]), JournalPage(number: 5, entries: [])]),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])])
            ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), shelfIndex: 0, bookIndex: 0, degrees: $degrees, isHidden: $isHidden, show: $show, frontDegrees: $frontDegrees, circleStart: $circleStart, circleEnd: $circleEnd, displayPageIndex: $displayPageIndex, coverZ: $cover, scaleFactor: $scaleFactor, inTextEntry: $inTextEntry, selectedEntry: $selectedEntry)
        }
    }

    return Preview()
}
