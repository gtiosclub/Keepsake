//
//  Reminder.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/29/25.
//

import Foundation
import SwiftUI
#if os(iOS)
import FirebaseFirestore
#endif
//
// Reminder Model

struct Reminder: Identifiable, Codable {
    #if os(iOS)
    @DocumentID var id: String?
    #endif
    #if os(watchOS)
    var id: String
    #endif
    var prompt: String
    var date: Date
//    var body: String
}
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct RemindersListView: View {
    @State private var navigateToRecording = false
    @EnvironmentObject private var viewModel: RemindersViewModel
    var audioRecording = AudioRecording()
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(viewModel.reminders) { reminder in
                    VStack(alignment: .leading) {
                        Text(reminder.date, style: .date)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 5)
                }
                #if os(watchOS)
                NavigationLink(
                    destination: AudioFilesView(),
                    label: {
                        HStack {
                            Image(systemName: "headphones")
                                .foregroundColor(Color(hex: "FFADF4"))
                            Text("Audio Recordings")
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.3)))
                        .shadow(radius: 5)
                    }
                )
                
                .padding(.vertical)
                #endif
                
                #if os(watchOS)
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
                .buttonStyle(PlainButtonStyle())
                #endif
            }
            .navigationDestination(isPresented: $navigateToRecording) {
                VoiceRecordingView(audioRecording: AudioRecording())
                   }
                   .onReceive(NotificationCenter.default.publisher(for: .navigateToVoiceRecording)) { _ in
                       navigateToRecording = true
                   }
        }
    }
}
