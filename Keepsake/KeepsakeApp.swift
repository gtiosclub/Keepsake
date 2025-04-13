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
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .list, .sound, .badge])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        
            let category = response.notification.request.content.categoryIdentifier
            DispatchQueue.main.async {
                switch category {
                        case "JOURNAL_CATEGORY":
                            NotificationCenter.default.post(name: .navigateToHome, object: nil)
                        case "PROFILE_REMINDER_CATEGORY":
                            NotificationCenter.default.post(name: .navigateToProfile, object: nil)
                        default:
                            break
                        }
            }
        
        completionHandler()
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
    let profileReminderCategory = UNNotificationCategory(identifier: "PROFILE_REMINDER_CATEGORY",
                                                             actions: [],
                                                             intentIdentifiers: [],
                                                             options: [])

    UNUserNotificationCenter.current().setNotificationCategories([category, profileReminderCategory])
}
func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
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
    @StateObject private var aiViewModel = AIViewModel()
      init() {
          requestNotificationPermission()
          
      }
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(firebaseViewModel)
                 .environmentObject(reminderViewModel)
                 .environmentObject(aiViewModel)

        }
        
    }
        
}
