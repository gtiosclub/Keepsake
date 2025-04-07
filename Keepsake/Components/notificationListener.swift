//
//  notificationListener.swift
//  Keepsake
//
//  Created by Nitya Potti on 4/5/25.
//


import SwiftUI
import UserNotifications

struct NotificationView: View {
    @State private var notificationTitle = ""
    @State private var notificationBody = ""

    var body: some View {
        VStack {
            Text(notificationTitle)
                .font(.headline)
                .padding()
            
            Text(notificationBody)
                .padding()
            
            Button("Dismiss") {
            }
        }
        .onAppear {
        }
    }
    func updateNotification(_ notification: UNNotification) {
        notificationTitle = notification.request.content.title
        notificationBody = notification.request.content.body
    }
    

}
//func scheduleReminderNotification(for reminder: Reminder) {
//    let content = UNMutableNotificationContent()
//    content.title = "Reminder to Journal"
//    content.body = "It's time to journal! Don't forget to write your thoughts for the day."
//    content.sound = .default
//    
//    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
//
//    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//
//    let request = UNNotificationRequest(identifier: reminder.id ?? UUID().uuidString, content: content, trigger: trigger)
//
//    UNUserNotificationCenter.current().add(request) { error in
//        if let error = error {
//            print("Error scheduling notification: \(error.localizedDescription)")
//        } else {
//            print("Notification scheduled for reminder with id: \(reminder.id)")
//        }
//    }
//}
//func scheduleNotificationsForAllReminders() {
//    // Assuming reminders have been fetched and are in Connectivity.shared.reminders
//    for reminder in Connectivity.shared.reminders {
//        // Check if reminder date is in the future
//        if reminder.date > Date() {
//            scheduleReminderNotification(for: reminder)
//        }
//    }
//}


