//
//  KeepsakeApp.swift
//  Keepsake
//
//  Created by Rik Roy on 2/2/25.
//


import UIKit
import UserNotifications
import SwiftUI
import FirebaseCore

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
        registerNotificationActions()
        return true
    }

}
func registerNotificationActions() {
    let recordAction = UNNotificationAction(identifier: "RECORD_ACTION",
                                            title: "Record",
                                            options: [.foreground])
    
    let category = UNNotificationCategory(identifier: "JOURNAL_CATEGORY",
                                          actions: [recordAction],
                                          intentIdentifiers: [],
                                          options: [])

    UNUserNotificationCenter.current().setNotificationCategories([category])
}
func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
}



@main
struct KeepsakeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebaseViewModel = FirebaseViewModel.vm
    @StateObject private var reminderViewModel = RemindersViewModel()
      init() {
          requestNotificationPermission()
      }
    var body: some Scene {
        WindowGroup {
             isLoggedInView()
                 .environmentObject(firebaseViewModel)
                 .environmentObject(reminderViewModel)

        }
    }
}
