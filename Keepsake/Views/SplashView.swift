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
    @State private var navigateToAudioFiles = false
    @State private var navigateToProfile = false
    let aiVM = AIViewModel()
        var body: some View {
            Group {
                if isActive {
                    NavigationStack {
                        if let user = viewModel.currentUser {
                            if navigateToHomeFromNotification {
                                ZStack {
                                    ContentView(
                                        userVM: UserViewModel(user: user),
                                        aiVM: aiVM,
                                        fbVM: viewModel,
                                        selectedTab: .home
                                    )
                                    .environmentObject(reminderViewModel)

                                    ViewControllerWrapper(aiViewModel: aiVM)
                                        .frame(width: 0, height: 0)
                                        .hidden()
                                }
                            } else if navigateToProfile {
                                ZStack {
                                    ContentView(
                                        userVM: UserViewModel(user: user),
                                        aiVM: aiVM,
                                        fbVM: viewModel,
                                        selectedTab: .profile
                                    )
                                    .environmentObject(reminderViewModel)

                                    ViewControllerWrapper(aiViewModel: aiVM)
                                        .frame(width: 0, height: 0)
                                        .hidden()
                                }
                            } else {
                                
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
                    .onReceive(NotificationCenter.default.publisher(for: .navigateToProfile)) { _ in
                          navigateToProfile = true
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
                if viewModel.initializedUser {
                    isActive = true
                }
            }
            
        }
    }

#Preview {
    SplashView()
}
