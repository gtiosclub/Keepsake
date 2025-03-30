//
//  ContentView.swift
//  Keepsake
//
//  Created by Nithya Ravula on 3/10/25.
//

import SwiftUI

struct isLoggedInView: View {
    @EnvironmentObject var viewModel: FirebaseViewModel
    @EnvironmentObject var reminderViewModel: RemindersViewModel
    var body: some View {
        Group {
            if let user = viewModel.currentUser {
                ContentView(userVM: UserViewModel(user: user), aiVM: AIViewModel(), fbVM: viewModel)
                    .environmentObject(reminderViewModel)
                
                
            } else {
                LoginView()
            }
        }
    }
}
