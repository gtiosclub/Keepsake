//
//  Reminder.swift
//  KeepsakeWatch Watch App
//
//  Created by Ishita on 2/17/25.
//

import Foundation
import SwiftUI
import UserNotifications
//
//// Reminder Model
struct Reminder: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var body: String
}


struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersListView()
    }
}

struct RemindersListView: View {
    @State private var reminders: [Reminder] = []
    @State private var showVoiceRecording = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Reminders")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "FFADF4"))
                    Spacer()
                    Button(action: { showVoiceRecording = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "FFADF4"))
                            .font(.title2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                List {
                    ForEach(reminders) { reminder in
                        VStack(alignment: .leading) {
                            Text(reminder.title)
                                .font(.headline)
                            Text("\(reminder.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .listStyle(PlainListStyle())
                
                .sheet(isPresented: $showVoiceRecording) {
                    VoiceRecordingView { newReminder in
                        reminders.append(newReminder)
                        showVoiceRecording = false
//                        NotificationManager.scheduleNotification(for: newReminder)
                    }
                }
            }
//            .onAppear {
//                #if !targetEnvironment(simulator)
//                do {
//                    NotificationManager.requestNotificationPermission()
//                } catch {
//                    print("Error")
//                }
//                #endif
//            }
        }
    }
}
