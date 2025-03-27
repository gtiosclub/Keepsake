//
//  ContentView.swift
//  Keepsake
//
//  Created by Nithya Ravula on 3/10/25.
//

import SwiftUI

struct isLoggedInView: View {
    @EnvironmentObject var viewModel: FirebaseViewModel
    var body: some View {
        Group {
            if let user = viewModel.currentUser {
                ContentView(userVM: UserViewModel(user: user), aiVM: AIViewModel(), fbVM: viewModel)
            } else {
                LoginView()
            }
        }
    }
}
