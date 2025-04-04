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
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // Two columns per row

    // Track selection states for circles and stars per page
    @State private var selectedCircles: [Int: Bool] = [:]
    @State private var selectedStars: [Int: Bool] = [:]
    
    // State to track the selected option (All or Favorites)
    @State private var selectedOption = 0 // 0: All, 1: Favorites
    
    @State var inEntry: EntryType = .openJournal
    @State var selectedEntry: Int = 0
    @State var showDeleteButton: Int = -1
    @State var frontDegrees: CGFloat = -180
    @State var isWiggling: Bool = false
    
    var body: some View {
        VStack {
            // Picker for toggling between All and Favorites
            Picker("Filter Pages", selection: $selectedOption) {
                Text("All").tag(0)
                Text("Favorites").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle()) // Segmented control style
            .padding()
            
            // Action Buttons
            HStack(spacing: 60) {
                ActionButton(icon: "document.on.document", label: "Duplicate")
                ActionButton(icon: "square.and.arrow.up", label: "Export")
                ActionButton(icon: "arrow.up.and.down.and.arrow.left.and.right", label: "Move")
                ActionButton(icon: "trash", label: "Trash")
            }
            .padding(.vertical, 10)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    // Filter pages based on the selected option
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
                                    selectedCircles[page.number]?.toggle()
                                }) {
                                    Image(systemName: (selectedCircles[page.number] ?? false) ? "circle.fill" : "circle")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor((selectedCircles[page.number] ?? false) ? .blue : .gray)
                                }
                                .padding(.leading, 8)
                                
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
                            
                            VStack {
                                let gridItems = [GridItem(.fixed(80), spacing: 10, alignment: .leading),
                                                 GridItem(.fixed(80), spacing: UIScreen.main.bounds.width * 0.02, alignment: .leading),]

                                LazyVGrid(columns: gridItems, spacing: UIScreen.main.bounds.width * 0.02) {
                                    ForEach(Array(zip(page.entries.indices, page.entries)), id: \.0) { index, widget in
                                        ZStack(alignment: .topLeading) {
                                            createView(for: widget, width: 80, height: 40, isDisplay: false, inEntry: $inEntry, selectedEntry: $selectedEntry, fbVM: fbVM, journal: journal, userVM: userVM, pageNum: page.number, entryIndex: index, frontDegrees: $frontDegrees, showDeleteButton: $showDeleteButton, isWiggling: $isWiggling)
                                        }
                                    }
                                }.padding(.top, 30)
                            }
                            .frame(width: 180, height: 250) // Ensure VStack takes the full space of the rectangle
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
                            print("Tapped on Page \(page.number)")
                        }
                    }
                    
                    // "Add Page" Button
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
                    }
                }

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
            return journal.pages.filter { selectedStars[$0.number] == true }
        }
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
            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: []))
        var body: some View {
            JournalPagesView(userVM: userVM, fbVM: FirebaseViewModel(), journal: userVM.getJournal(shelfIndex: 0, bookIndex: 0), isPresented: $isPresented)
        }
    }

    return Preview()
}
