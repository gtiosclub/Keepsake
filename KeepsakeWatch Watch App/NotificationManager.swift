import Foundation
import UserNotifications
import SwiftUI

// Notification Manager to handle permissions and notification scheduling
class NotificationManager {
    
    // Function to request notification permissions
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    // Function to schedule a notification
    static func scheduleNotification(title: String, body: String, timeInterval: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
    
    // Function to schedule a notification for a journal prompt
    static func scheduleJournalPromptNotification(prompt: String) {
        scheduleNotification(title: "New Journal Prompt", body: prompt)
    }
    
    // Function to schedule a notification for topic completion
    static func scheduleTopicCompletionNotification(question: String) {
        scheduleNotification(title: "Continue Your Journal", body: question)
    }
}

// SwiftUI preview for notification appearance
struct NotificationPreview: View {
    var body: some View {
        VStack {
            Text("Notification Preview")
                .font(.title2)
                .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text("📌 Reminder")
                    .font(.headline)
                Text("Reminder: Sample notification")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding()
        }
    }
}

#Preview {
    NotificationPreview()
}




