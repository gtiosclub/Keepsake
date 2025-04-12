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
                                let aiVM = AIViewModel()
                                ZStack {
                                    ContentView(
                                        userVM: UserViewModel(user: user),
                                        aiVM: aiVM,
                                        fbVM: viewModel
                                    )
                                    .environmentObject(reminderViewModel)

                                    ViewControllerWrapper(aiViewModel: aiVM)
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
                    VStack(spacing: 8) {
                        Image("KeepsakeIcon")
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text("Keepsake")
                            .font(.system(size: 60, weight: .semibold))
                        
                        Spacer().frame(height: 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                }
            }
            .onChange(of: viewModel.initializedUser) { newValue in
                if newValue {
                    withAnimation {
                        isActive = true
                    }
                }
            }
            .onAppear {
                // If initializedUser is already true (from previous runs)
                if viewModel.initializedUser {
                    isActive = true
                }
            }
        }
    }

#Preview {
    SplashView()
}
