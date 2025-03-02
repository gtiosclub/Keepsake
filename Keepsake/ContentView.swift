////
////  ContentView.swift
////  Keepsake
////
////  Created by Rik Roy on 2/2/25.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        TabView {
//            Tab("Home", systemImage: "house") {
//                HomepageView(shelf: Shelf(name: "Bookshelf", books: [
//                    Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .red, pageColor: .white, titleColor: .black), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
//                    Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(coverColor: .green, pageColor: .white, titleColor: .black), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
//                    Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(coverColor: .blue, pageColor: .black, titleColor: .white), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
//                    Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(coverColor: .brown, pageColor: .white, titleColor: .black), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])])
//                ]))
//            }
//
//
//            Tab("Community", systemImage: "person.2") {
//                CommunityView()
//            }
//        }.onAppear {
//            // correct the transparency bug for Tab bars
//            let tabBarAppearance = UITabBarAppearance()
//            tabBarAppearance.configureWithOpaqueBackground()
//            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//            // correct the transparency bug for Navigation bars
//            let navigationBarAppearance = UINavigationBarAppearance()
//            navigationBarAppearance.configureWithOpaqueBackground()
//            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
import SwiftUI
import UserNotifications
import WatchConnectivity

struct ContentView: View {
    @State private var notificationMessage: String = "No notifications yet"
        
        var body: some View {
            ViewControllerWrapper()
                .frame(width: 0, height: 0)
            VStack {
                Text(notificationMessage)
                    .font(.title)
                    .padding()
                
                Button(action: {
                    sendLocalNotification()
                }) {
                    Text("Send Local Notification")
                }
                .padding()
            }
        }
        
    func sendLocalNotification() {
        // Create the content of the notification
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification sent from the app."
        content.sound = .default

        // Set the category for the notification, which will allow banner action buttons if needed.
        content.categoryIdentifier = "TEST_NOTIFICATION"

        // Create a trigger (immediate notification with no trigger)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Create the notification request
        let request = UNNotificationRequest(identifier: "TestNotification", content: content, trigger: trigger)

        // Add the notification request to the center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent successfully!")
            }
        }
    }

}
