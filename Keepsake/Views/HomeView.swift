//
//  HomeView.swift
//  Keepsake
//
//  Created by Alec Hance on 3/24/25.
//

import SwiftUI

enum ViewOption {
    case journal_shelf
    case library
    case scrapbook_shelf
}

struct HomeView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    @State var selectedOption: ViewOption = .library
    @State var jIndex: Int = 0
    @State var sIndex: Int = 0
    @State var showScrapbookForm: Bool = false
    var body: some View {
        Group {
            switch selectedOption {
            case .journal_shelf:
                ShelfView(userVM: userVM, shelf: userVM.getJournalShelves()[jIndex], aiVM: aiVM, fbVM: fbVM, shelfIndex: jIndex, selectedOption: $selectedOption)
            case .library:
                LibraryView(userVM: userVM, aiVM: aiVM, fbVM: fbVM, selectedOption: $selectedOption)
            case .scrapbook_shelf:
                ScrapbookShelfView(userVM: userVM, shelf: userVM.getScrapbookShelves()[sIndex], aiVM: aiVM, fbVM: fbVM, shelfIndex: sIndex, showScrapbookForm: $showScrapbookForm, selectedOption: $selectedOption)
            }
        }
        .onAppear {
            selectedOption = userVM.user.isJournalLastUsed ? .journal_shelf : .scrapbook_shelf
            let tempIsJournal = userVM.user.isJournalLastUsed
            userVM.setShelfToLastUsedSShelf()
            userVM.setShelfToLastUsedJShelf()
            jIndex = userVM.getJournalShelfIndex()
            sIndex = userVM.getScrapbookShelfIndex()
            userVM.setLastUsed(isJournal: tempIsJournal)
        }
        .onChange(of: userVM.getJournalShelfIndex(), {
            jIndex = userVM.getJournalShelfIndex()
        })
        .onChange(of: userVM.getScrapbookShelfIndex(), {
            sIndex = userVM.getScrapbookShelfIndex()
        })
        .sheet(isPresented: $showScrapbookForm) {
            ScrapbookFormView(
                isPresented: $showScrapbookForm,
                onCreate: { title, coverColor, pageColor, titleColor, texture, journalPages in
                    Task {
                        await createScrapbook(
                            from: Template(name: title, coverColor: coverColor, pageColor: pageColor, titleColor: titleColor, texture: texture, journalPages: journalPages),
                            shelfIndex: sIndex, shelfID: userVM.getScrapbookShelves()[sIndex].id
                        )
                    }
                },
                templates: userVM.user.savedTemplates, userVM: userVM, fbVM: fbVM
            )
        }
    }
    
    func createScrapbook(from template: Template, shelfIndex: Int, shelfID: UUID) async {
        let newScrapbook = Scrapbook(
            name: template.name,
            id: UUID(),
            createdDate: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            category: "General",
            isSaved: false,
            isShared: false,
            template: template,
            pages: [ScrapbookPage(number: 0, entries: [], entryCount: 0)],
            currentPage: 0
        )
        userVM.addScrapbookToShelf(scrapbook: newScrapbook, shelfIndex: sIndex)
        await fbVM.addScrapbook(scrapbook: newScrapbook, scrapbookShelfID: shelfID)
       
    }
}

//#Preview {
//    HomeView()
//}
