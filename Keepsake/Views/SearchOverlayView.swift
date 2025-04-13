//
//  SearchOverlayView.swift
//  Keepsake
//
//  Created by Rik Roy on 3/11/25.
//

import SwiftUI

struct SearchOverlayView: View {
    @State private var isSearching = false
    @Binding var isPresented: Bool // Control visibility from the parent view
    @State private var searchText = ""
    @State private var debounceTask: DispatchWorkItem?
    @ObservedObject var firebaseVM: FirebaseViewModel
    @Binding var inEntry: EntryType
    @Binding var selectedEntry: Int
    @ObservedObject var journal: Journal
    @Binding var displayPageIndex: Int
    
    var journalID = ""

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear) // Fully transparent
                .contentShape(Rectangle()) // Make the entire rectangle tappable
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                    
                    TextField("", text: $searchText, prompt: Text("Search").foregroundColor(.gray))
                        .foregroundStyle(Color.white)
                        .onChange(of: searchText) { newValue in
                            debounceSearch(term: newValue)
                        }
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.9)
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    }
                }
                
                ForEach(firebaseVM.searchedEntries, id: \.self) { journalEntry in
                    Divider()
                        .overlay(Color.gray)
                    JournalTextWidgetView(entry: journalEntry)
                        .onTapGesture {
                            print("Tapped entry ID: \(journalEntry.id)")
                            
                            for (pageIndex, page) in journal.pages.enumerated() {
                                if let entryIndex = page.entries.firstIndex(where: { $0.id == journalEntry.id }) {
                                    print(entryIndex)
                                    selectedEntry = entryIndex
                                    displayPageIndex = pageIndex
                                    inEntry = journalEntry.type
                                    break
                                }
                            }
                            
                        }
                }
            }
            .padding() // Add padding around the VStack
            .background(Color(red: 73/256, green: 79/256, blue: 84/256)) // Set the background color for the VStack
            .cornerRadius(12) // Round the corners of the VStack
            .shadow(color: Color.black.opacity(0.6), radius: 10, x: 5, y: 5)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .padding(.horizontal, 10)

        }
        .onDisappear {
            firebaseVM.searchedEntries.removeAll()
        }
        
       
    }

    private func debounceSearch(term: String) {
        debounceTask?.cancel()
        isSearching = true
        let task = DispatchWorkItem {
            Task {
                await FirebaseViewModel.vm.performVectorSearch(searchTerm: term, journal_id: journal.id.uuidString)
                isSearching = false
            }
        }
        debounceTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: task)
    }
}

#Preview("iPhone Preview") {
    @State var var1 = true
    SearchOverlayView(isPresented: $var1, firebaseVM: FirebaseViewModel.vm, inEntry: .constant(.written), selectedEntry: .constant(0), journal: Journal(), displayPageIndex: .constant(0))
}
