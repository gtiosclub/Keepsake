//
//  NewPageView.swift
//  Keepsake
//
//  Created by Alec Hance on 4/6/25.
//

import SwiftUI

struct NewPageView: View {
    var pageTemplateTitles: [String] = ["Blank","Default", "Daily Reflection", "Trip"]
    @State var inEntry: EntryType = .openJournal
    @State var selectedEntry: Int = 0
    @State var showDeleteButton: Int = -1
    @State var frontDegrees: CGFloat = -180
    @State var isWiggling: Bool = false
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    @ObservedObject var journal: Journal
    @Binding var isPresented: Bool
    @Binding var showNewPage: Bool
    @Binding var displayPage: Int
    
    @State var pageTemplates: [JournalPage] = []
    // Define grid columns (2 columns in this case)
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack {
            Button {
                showNewPage.toggle()
            } label: {
                Image(systemName: "chevron.left")
                Text("Back")
            }.buttonStyle(.plain).padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                
            Text("Create a New Page")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 5)
            
            // Vertical ScrollView with LazyVGrid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(pageTemplates.indices, id: \.self) { index in
                        VStack {
                            // Template title
                            Text(pageTemplateTitles[index])
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            // Paper-like rectangle
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(radius: 5)
                                    .frame(width: 180, height: 250)
                                
                                VStack {
                                    let gridItems = [
                                        GridItem(.fixed(75), spacing: UIScreen.main.bounds.width * 0.015),
                                        GridItem(.fixed(75), spacing: UIScreen.main.bounds.width * 0.015)
                                    ]
                                    
                                    LazyVGrid(columns: gridItems, spacing: UIScreen.main.bounds.width * 0.015) {
                                        ForEach(Array(zip(pageTemplates[index].entries.indices, pageTemplates[index].entries)), id: \.0) { indice, widget in
                                            ZStack {
                                                createView(
                                                    for: widget,
                                                    width: 75,
                                                    height: 53,
                                                    padding: 0.01,
                                                    isDisplay: false,
                                                    inEntry: $inEntry,
                                                    selectedEntry: $selectedEntry,
                                                    fbVM: fbVM,
                                                    journal: journal,
                                                    userVM: userVM,
                                                    pageNum: pageTemplates[index].number,
                                                    entryIndex: indice,
                                                    frontDegrees: $frontDegrees,
                                                    showDeleteButton: $showDeleteButton,
                                                    isWiggling: $isWiggling,
                                                    fontSize: 10
                                                )
                                            }.allowsHitTesting(false)
                                                .offset(y: -4)
                                        }
                                    }
                                    .padding(.top, 15)
                                }
                                .frame(width: 180, height: 250)
                            }.onTapGesture {
                                userVM.addPage(page: pageTemplates[index], journal: journal)
                                Task {
                                    await fbVM.updateJournalPage(entries: pageTemplates[index].entries, journalID: journal.id, pageNumber: journal.pages.count - 1)
                                }
                                displayPage = journal.pages.count - 1
                                journal.currentPage = displayPage
                                showNewPage.toggle()
                                isPresented.toggle()
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                
            }
            .padding(.top)
        }
        .onAppear() {
            pageTemplates = [JournalPage(number: 1), JournalPage.defaultTemplate(pageNumber: 1, color: journal.template.coverColor),  JournalPage.dailyReflectionTemplate(pageNumber: 1, color: journal.template.coverColor), JournalPage.tripTemplate(pageNumber: 1, color: journal.template.coverColor)]
        }
    }
}

#Preview {
    struct Preview: View {
        @State var showNewPageSheet: Bool = true
        @State var isPresented: Bool = true
        @State var displayPage: Int = 0
        var body: some View {
            NewPageView(userVM: UserViewModel(user: User()), fbVM: FirebaseViewModel(), journal: Journal(), isPresented: $isPresented, showNewPage: $showNewPageSheet, displayPage: $displayPage)
        }
    }

    return Preview()
}
