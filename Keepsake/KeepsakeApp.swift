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
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()

        return true
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
