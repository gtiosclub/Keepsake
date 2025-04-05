//
//  JournalPageView.swift
//  Keepsake
//
//  Created by Ganden Fung on 3/31/25.
//

import SwiftUI

struct JournalPagesView: View {
    let journal: Journal
    @Binding var isPresented: Bool
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // Two columns per row

    // Track selection states for circles and stars per page
    @State private var selectedCircles: [Int: Bool] = [:]
    @State private var selectedStars: [Int: Bool] = [:]
    
    // State to track the selected option (All or Favorites)
    @State private var selectedOption = 0 // 0: All, 1: Favorites
    
    var body: some View {
        NavigationView {
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
                                
                                // Centered Page Number Text
                                VStack {
                                    Spacer()
                                    Text("Page \(page.number)")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                    Spacer()
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
                    .padding()
                }
            }
            .navigationTitle("Page Elements")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        isPresented = false
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


struct JournalPagesView_Previews: PreviewProvider {
    static var previews: some View {
        JournalPagesView(
            journal: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
            isPresented: .constant(true)
        )
    }
}
