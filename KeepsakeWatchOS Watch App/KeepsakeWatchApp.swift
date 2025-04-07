//
//  KeepsakeWatchApp.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 2/10/25.
//

import SwiftUI
import UserNotifications
extension Notification.Name {
    static let navigateToVoiceRecording = Notification.Name("navigateToVoiceRecording")
}
@main
struct KeepsakeWatch_Watch_AppApp: App {
    @StateObject private var viewModel = RemindersViewModel()
    @WKExtensionDelegateAdaptor(AppDelegate.self) var appDelegate 
    
    var body: some Scene {
        WindowGroup {
            RemindersListView()
                .environmentObject(viewModel)
        }
    }
}

class AppDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {

    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if response.actionIdentifier == "RECORD_ACTION" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .navigateToVoiceRecording, object: nil)
            }
        }
    }
    
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
