//
//  Choice.swift
//  Keepsake
//
//  Created by Nitya Potti on 3/29/25.
//
import SwiftUI
import Foundation

struct Choice: View {
    @EnvironmentObject private var viewModel: RemindersViewModel
    

    var body: some View {
        VStack {
            NavigationLink(
                destination: TextReminder()
                    .environmentObject(viewModel),
                label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "FFADF4"))
                        .font(.title)
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.3)))
                        .shadow(radius: 10)
                }
            )
            .buttonStyle(PlainButtonStyle()) // To remove default button style
            NavigationLink(
                destination: VoiceRecordingView(onRecordingComplete: { _ in }),
                label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "FFADF4"))
                        .font(.title)
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.3)))
                        .shadow(radius: 10)
                }
            )
            .buttonStyle(PlainButtonStyle()) // To remove default button style
        }
    }
}

