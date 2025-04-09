//
//  SplashView.swift
//  Keepsake
//
//  Created by Shlok Patel on 4/7/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var viewModel: FirebaseViewModel
    @EnvironmentObject var reminderViewModel: RemindersViewModel
    @State private var isActive = false
    @State private var navigateToHomeFromNotification = false

        var body: some View {
            Group {
                if isActive {
                    NavigationStack {
                        if let user = viewModel.currentUser {
                            if navigateToHomeFromNotification {
                                HomeView(
                                    userVM: UserViewModel(user: user),
                                    aiVM: AIViewModel(),
                                    fbVM: viewModel
                                )
                            } else {
                                ZStack {
                                    ContentView(
                                        userVM: UserViewModel(user: user),
                                        aiVM: AIViewModel(),
                                        fbVM: viewModel
                                    )
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
                } else {
                    VStack {
                        Text("Keepsake")
                            .font(.system(size: 60, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }

#Preview {
    SplashView()
}
