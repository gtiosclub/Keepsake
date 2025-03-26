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
                ContentView(userVM: UserViewModel(user: user), aiVM: AIViewModel(), fbVM: viewModel)
            } else {
                LoginView()
            }
        }
    }
}

//#Preview {
//    FirstView()
//}
