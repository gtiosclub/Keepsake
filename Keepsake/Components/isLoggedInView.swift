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
    var body: some View {
        NavigationStack {
            Group {
                if let user = viewModel.currentUser {
                    if navigateToHomeFromNotification {
                        HomeView(userVM: UserViewModel(user: user), aiVM: AIViewModel(), fbVM: viewModel)
                    } else {
                        ZStack {
                            ContentView(userVM: UserViewModel(user: user), aiVM: AIViewModel(), fbVM: viewModel)
                                .environmentObject(reminderViewModel)
                            ViewControllerWrapper()
                                .frame(width: 0, height: 0)
                                .hidden()
                        }
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

