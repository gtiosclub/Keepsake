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
    var body: some View {
        Group {
            switch selectedOption {
            case .journal_shelf:
                ShelfView(userVM: userVM, shelf: userVM.getJournalShelves()[userVM.getJournalShelfIndex()], aiVM: aiVM, fbVM: fbVM, shelfIndex: userVM.getJournalShelfIndex(), selectedOption: $selectedOption)
            case .library:
                LibraryView(userVM: userVM, aiVM: aiVM, fbVM: fbVM, selectedOption: $selectedOption)
            case .scrapbook_shelf:
                ScrapbookShelfView(userVM: userVM, shelf: userVM.getScrapbookShelves()[userVM.getScrapbookShelfIndex()], aiVM: aiVM, fbVM: fbVM, shelfIndex: userVM.getScrapbookShelfIndex(), selectedOption: $selectedOption)
            }
        }
        .onAppear {
            selectedOption = userVM.user.isJournalLastUsed ? .journal_shelf : .scrapbook_shelf
            let tempIsJournal = userVM.user.isJournalLastUsed
            userVM.setShelfToLastUsedJShelf()
            userVM.setShelfToLastUsedSShelf()
            userVM.setLastUsed(isJournal: tempIsJournal)
        }
    }
}

//#Preview {
//    HomeView()
//}
