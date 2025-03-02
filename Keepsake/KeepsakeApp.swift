//
//  KeepsakeApp.swift
//  Keepsake
//
//  Created by Rik Roy on 2/2/25.
//

import SwiftUI

import FirebaseCore

import UIKit
import UserNotifications



import UIKit
import UserNotifications


import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()

        // Request Notification permission for iOS
        UNUserNotificationCenter.current().delegate = self
        
        // Request authorization to send notifications
        requestNotificationPermission()

        return true
    }

    // Method to handle the notification when it's received
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner and sound even when the app is in the foreground
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle tap on the notification
        print("Notification tapped: \(response.notification.request.content.body)")
        completionHandler()
    }
}


@main
struct KeepsakeApp: App {
    init() {
            requestNotificationPermission()
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebaseViewModel = FirebaseViewModel.vm
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
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
