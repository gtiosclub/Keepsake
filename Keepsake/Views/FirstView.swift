//
//  FirstView.swift
//  Keepsake
//
//  Created by Nithya Ravula on 3/12/25.
//

import SwiftUI

struct FirstView: View {
    @EnvironmentObject var viewModel: FirebaseViewModel
    var body: some View {
        Group {
            if let user = viewModel.currentUser {
                HomeView(userVM: UserViewModel(user: user), aiVM: AIViewModel(), fbVM: viewModel, selectedOption: .journal_shelf)
            } else {
                LoginView()
            }
        }
    }
}

//#Preview {
//    FirstView()
//}
