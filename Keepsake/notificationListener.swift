
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
                // Handle dismissal or any action on notification
            }
        }
        .onAppear {
            // Listen for notification updates here
        }
    }
    
    // Add a function to handle incoming notifications
    func updateNotification(_ notification: UNNotification) {
        notificationTitle = notification.request.content.title
        notificationBody = notification.request.content.body
    }
}
