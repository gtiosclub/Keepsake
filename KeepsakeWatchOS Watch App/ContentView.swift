//
//  ContentView.swift
//  KeepsakeWatchOS Watch App
//
//  Created by Nitya Potti on 3/29/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Image("KeepsakeIcon")
                .resizable()
                .frame(width: 50, height: 50)
            Text("Keepsake")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(Color(hex: "FFADF4"))
            
            //Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea()

    }
}

struct ContentView: View {
    @State var isActive = false
    @EnvironmentObject private var viewModel: RemindersViewModel
    var body: some View {
        Group {
            if isActive {
//                RemindersListView()
//                    .environmentObject(viewModel)
                VoiceRecordingView(onRecordingComplete: { _ in })
            } else {
                SplashView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}
