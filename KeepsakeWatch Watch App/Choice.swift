//
//  Choice.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/5/25.
//

import Foundation
import SwiftUI

struct Choice: View {
    @State var reminders: [Reminder]
    @State var showVoiceRecording: Bool
    init(reminders: [Reminder], showVoiceRecording: Bool) {
         self.reminders = reminders
         self.showVoiceRecording = showVoiceRecording
     }
    var body: some View {
        
        
        NavigationLink(
            destination: VoiceRecordingView { recordedFile in
                reminders.append(recordedFile)
                showVoiceRecording = false
            },
            label: {
                Text("Record your thoughts")
                    .foregroundColor(Color(hex: "FFADF4"))
                    .font(.body)
                    .padding()
                    .cornerRadius(20)
                    .shadow(radius: 10)
            }
        )
        NavigationLink(
            destination: TextReminder() { recordedFile in
                reminders.append(recordedFile)
                showVoiceRecording = false
            },
            label: {
                Text("Make a Reminder")
                    .foregroundColor(Color(hex: "FFADF4"))
                    .font(.body)
                    .padding()
                    .cornerRadius(20)
                    .shadow(radius: 10)
            }
        )
    }
}
