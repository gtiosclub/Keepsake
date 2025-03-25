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
}

struct HomeView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    @State var selectedOption: ViewOption = .journal_shelf
    var body: some View {
        switch selectedOption {
        case .journal_shelf:
            ShelfView(userVM: userVM, shelf: userVM.getJournalShelves()[userVM.getShelfIndex()], aiVM: aiVM, fbVM: fbVM, shelfIndex: userVM.getShelfIndex(), selectedOption: $selectedOption)
        case .library:
            LibraryView(userVM: userVM, aiVM: aiVM, fbVM: fbVM, selectedOption: $selectedOption)
        }
    }
}

//#Preview {
//    HomeView()
//}
