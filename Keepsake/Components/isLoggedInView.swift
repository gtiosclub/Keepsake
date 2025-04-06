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
    @State private var navigateToHomeFromNotification = false
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var userVM: UserViewModel
    var body: some View {
        NavigationStack {
            Group {
                if let user = viewModel.currentUser {
                    if navigateToHomeFromNotification {
                        HomeView(userVM: userVM, aiVM: aiVM, fbVM: viewModel)
                    } else {
                        ContentView(userVM: UserViewModel(user: user), aiVM: AIViewModel(), fbVM: viewModel)
                            .environmentObject(reminderViewModel)
                    }
                    
                    
                    
                } else {
                    LoginView()
                }
                
            }
            .onReceive(NotificationCenter.default.publisher(for: .navigateToHome)) { _ in
                navigateToHomeFromNotification = true
            }
        }
    }
}

