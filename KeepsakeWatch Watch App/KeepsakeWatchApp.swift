//
//  KeepsakeWatchApp.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 2/10/25.
//
import SwiftUI
import UserNotifications

@main
struct KeepsakeWatch_Watch_AppApp: App {
    @StateObject private var viewModel = RemindersViewModel()
    @WKExtensionDelegateAdaptor(AppDelegate.self) var appDelegate  // This is for watchOS instead of iOS
    
    var body: some Scene {
        WindowGroup {
            RemindersListView()
                .environmentObject(viewModel)
        }
    }
}

class AppDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {

    // This method runs when the watchOS app is launched.
    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
    }
    
    // Handle notifications when the app is active in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async {
        // Handle notification when received in the foreground
        // You can update your SwiftUI view here if needed
    }

    // Handle user interaction when a notification is tapped.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // Handle user interaction (e.g., tapping the notification)
    }
    
    // Request notification permissions
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
}
