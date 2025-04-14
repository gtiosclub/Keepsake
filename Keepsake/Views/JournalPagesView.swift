//
//  JournalPageView.swift
//  Keepsake
//
//  Created by Ganden Fung on 3/31/25.
//

import SwiftUI

struct JournalPagesView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    @ObservedObject var journal: Journal
    @Binding var isPresented: Bool
    @Binding var showNewPageSheet: Bool
    @Binding var displayPage: Int
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // Two columns per row
    
    // Track selection states for circles and stars per page
    @State private var selectedCircles: [Int: Bool] = [:]
    @State private var selectedStars: [Int: Bool] = [:] {
        didSet {
            updateFavoritePages()
            Task {
                await fbVM.updateFavoritePages(journalID: journal.id, newPages: journal.favoritePages)
            }
        }
    }
    
    // State to track the selected option (All or Favorites)
    @State private var selectedOption = 0 // 0: All, 1: Favorites
    
    @State var inEntry: EntryType = .openJournal
    @State var selectedEntry: Int = 0
    @State var showDeleteButton: Int = -1
    @State var frontDegrees: CGFloat = -180
    @State var isWiggling: Bool = false
    @State var deletePage: Int = -1
    @State var pageWiggling: Bool = false
    var body: some View {
        VStack {
            // Picker for toggling between All and Favorites
            Text("Page Elements")
                .font(.title)
                .padding(.vertical, 8)
            Picker("Filter Pages", selection: $selectedOption) {
                Text("All").tag(0)
                Text("Favorites").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle()) // Segmented control style
            .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    // Filter pages based on the selected option
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 180, height: 250) // Adjusted to match new paper size
                            .shadow(radius: 5)
                        
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                    }
                    .onTapGesture {
                        print("Tapped Add Page")
                        showNewPageSheet.toggle()
                    }
                    ForEach(filteredPages(), id: \.number) { page in
                        ZStack(alignment: .topLeading) {
                            // Rectangle shaped like a paper
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(radius: 5)
                                .frame(width: 180, height: 250) // Adjusted to look more like paper
                            
                            HStack {
                                // Circle (Top-left)
                                Button(action: {
                                    if journal.pages.count > 1 {
                                        updateSelectedStars(afterDeleting: page.number)
                                        userVM.deletePage(journal: journal, pageNumber: page.number)
                                        Task {
                                            await fbVM.deletePage(journalID: journal.id, pageNumber: page.number)
                                        }
                                    }
                                    for num in journal.favoritePages {
                                        selectedStars[num] = true
                                    }
                                    deletePage = -1
                                    pageWiggling = false
                                    if displayPage + 1 == page.number {
                                        displayPage = page.number == 1 ? 0 : displayPage - 1
                                    } else if displayPage + 1 > page.number {
                                        displayPage = displayPage - 1
                                    }
                                    journal.currentPage = displayPage
                                    Task {
                                        await fbVM.updateCurrentPage(journalID: journal.id, currentPage: journal.currentPage)
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(.black)
                                }
                                .padding(.leading, 8)
                                .opacity(deletePage == page.number ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: deletePage)
                                
                                Spacer()
                                
                                // Star (Top-right, properly inside the rectangle)
                                Button(action: {
                                    selectedStars[page.number]?.toggle()
                                }) {
                                    Image(systemName: (selectedStars[page.number] ?? false) ? "star.fill" : "star")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor((selectedStars[page.number] ?? false) ? .yellow : .gray)
                                }
                                .padding(.trailing, 8)
                            }
                            .frame(width: 180) // Ensure the buttons align within the rectangle
                            .padding(.top, 6)
                            
                            ZStack {
                                let gridItems = [GridItem(.fixed(75), spacing: UIScreen.main.bounds.width * 0.01, alignment: .leading),
                                                 GridItem(.fixed(75), spacing: UIScreen.main.bounds.width * 0.01, alignment: .leading),]
                                
                                LazyVGrid(columns: gridItems, spacing: UIScreen.main.bounds.width * 0.01) {
                                    ForEach(Array(zip(page.entries.indices, page.entries)), id: \.0) { index, widget in
                                        ZStack(alignment: .topLeading) {
                                            createView(for: widget, width: 75, height: 45, padding: 0.01, isDisplay: false, inEntry: $inEntry, selectedEntry: $selectedEntry, fbVM: fbVM, journal: journal, userVM: userVM, pageNum: page.number, entryIndex: index, frontDegrees: $frontDegrees, showDeleteButton: $showDeleteButton, isWiggling: $isWiggling, fontSize: 10)
                                        }.allowsHitTesting(false)
                                    }
                                }.padding(.top, 15)
                            }
                            .frame(width: 180, height: 250)
                        }
                        .onAppear {
                            if selectedCircles[page.number] == nil {
                                selectedCircles[page.number] = false
                            }
                            if selectedStars[page.number] == nil {
                                selectedStars[page.number] = false
                            }
                        }
                        .onTapGesture {
                            if deletePage != -1 {
                                deletePage = -1
                                pageWiggling = false
                            } else {
                                displayPage = page.number - 1
                                journal.currentPage = displayPage
                                Task {
                                    await fbVM.updateCurrentPage(journalID: journal.id, currentPage: journal.currentPage)
                                }
                                isPresented.toggle()
                            }
                        }
                        .onLongPressGesture {
                            if (pageWiggling == true) {
                                deletePage = -1
                                pageWiggling = false
                            }
                            withAnimation {
                                deletePage = page.number
                                pageWiggling = true
                            }
                        }
                        .rotationEffect(.degrees(pageWiggling && deletePage == page.number ? 2 : 0)) // Wiggle effect
                        .animation(pageWiggling && deletePage == page.number ?
                                   Animation.easeInOut(duration: 0.1).repeatForever(autoreverses: true)
                                   : .default, value: pageWiggling)
                    }
                    
                    // "Add Page" Button
                }
                
            }
        }.onAppear() {
            for num in journal.favoritePages {
                selectedStars[num] = true
            }
        }
        
    }
    
    // A computed property to filter pages based on the selected option (All or Favorites)
    private func filteredPages() -> [JournalPage] {
        if selectedOption == 0 {
            // Show all pages
            return journal.pages
        } else {
            // Show only favorite pages (where star is selected)
            return journal.pages.filter { page in
                journal.favoritePages.contains(page.number)
            }
        }
    }
    
    private func updateFavoritePages() {
        journal.favoritePages = selectedStars
            .filter { $0.value }
            .map { $0.key }
    }
    
    func updateSelectedStars(afterDeleting pageNumber: Int) {
        // Create a new dictionary to store updated mappings
        var updatedStars = [Int: Bool]()
        // Iterate through all starred pages
        for (num, isStarred) in selectedStars {
            if num == pageNumber {
                // Skip the deleted page
                continue
            } else if num > pageNumber {
                // Shift stars down by 1 for higher-numbered pages
                updatedStars[num - 1] = isStarred
            } else {
                // Keep stars for lower-numbered pages
                updatedStars[num] = isStarred
            }
        }
        // Update the state
        selectedStars = updatedStars
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
            Text(label)
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}


#Preview {
    struct Preview: View {
        @State var isPresented: Bool = true
        @ObservedObject var userVM: UserViewModel = UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [    JournalPage.dailyReflectionTemplate(pageNumber: 1, color: .green), JournalPage.tripTemplate(pageNumber: 2, color: .red), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ]), JournalShelf(name: "Shelf 2", journals: [
            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ])], scrapbookShelves: []))
        @State var showNewPageSheet: Bool = false
        @State var displayPage: Int = 0
        var body: some View {
            JournalPagesView(userVM: userVM, fbVM: FirebaseViewModel(), journal: userVM.getJournal(shelfIndex: 0, bookIndex: 0), isPresented: $isPresented, showNewPageSheet: $showNewPageSheet, displayPage: $displayPage)
        }
    }

    return Preview()
}
