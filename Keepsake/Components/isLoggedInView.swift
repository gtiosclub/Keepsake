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
    @EnvironmentObject var aiViewModel: AIViewModel
    @State private var navigateToHomeFromNotification = false
    @State private var navigateToProfile = false
    var body: some View {
        NavigationStack {
            Group {
                if let user = viewModel.currentUser {
                    if navigateToHomeFromNotification {
                        HomeView(userVM: UserViewModel(user: user), aiVM: aiViewModel, fbVM: viewModel)
                    } else if navigateToProfile {
                        ProfileView()
                    } else {
                        ZStack {
                            ContentView(userVM: UserViewModel(user: user), aiVM: aiViewModel, fbVM: viewModel)
                                .environmentObject(reminderViewModel)
                            ViewControllerWrapper(aiViewModel: aiViewModel)
                                .frame(width: 0, height: 0)
                                .hidden()
                        }
                    }
                } else {
                    LoginView()
                }
            }
//            .onReceive(NotificationCenter.default.publisher(for: .navigateToHome)) { _ in
//                navigateToHomeFromNotification = true
//            }
//            .onReceive(NotificationCenter.default.publisher(for: .navigateToHome)) { _ in
//                navigateToProfile = true
//            }
        }
    }
}

