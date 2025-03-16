//
//  Choice.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/5/25.
//
import SwiftUI
import Foundation
//struct Choice: View {
//    @State var reminders: [Reminder]
//    @State var showVoiceRecording: Bool
//    var onComplete: (Reminder) -> Void
//    
//    init(reminders: [Reminder], showVoiceRecording: Bool, onComplete: @escaping (Reminder) -> Void) {
//        self._reminders = State(initialValue: reminders)
//        self._showVoiceRecording = State(initialValue: showVoiceRecording)
//        self.onComplete = onComplete
//    }
//
//    var body: some View {
//        VStack {
//            NavigationLink(
//                destination: VoiceRecordingView { recordedFile in
//                    reminders.append(recordedFile) // Add the voice recording reminder to the list
//                    showVoiceRecording = false
//                },
//                label: {
//                    Text("Record your thoughts")
//                        .foregroundColor(Color(hex: "FFADF4"))
//                        .font(.body)
//                        .padding()
//                        .cornerRadius(20)
//                        .shadow(radius: 10)
//                }
//            )
//            
//            NavigationLink(
//                destination: TextReminder(onComplete: { newReminder in
//                    reminders.append(newReminder)
//                    onComplete(newReminder)
//                }),
//                label: {
//                    Text("Make a Reminder")
//                        .foregroundColor(Color(hex: "FFADF4"))
//                        .font(.body)
//                        .padding()
//                        .cornerRadius(20)
//                        .shadow(radius: 10)
//                }
//            )
//        }
//    }
//}


struct Choice: View {
    @EnvironmentObject var viewModel: RemindersViewModel

    var body: some View {
        VStack {
            NavigationLink(destination: TextReminder()) {
                Text("Make a Reminder")
            }
        }
    }
}
