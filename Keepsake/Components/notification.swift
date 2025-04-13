//
//  notification.swift
//  Keepsake
//
//  Created by Nitya Potti on 4/5/25.
//

//Tutorial used: https://www.youtube.com/watch?v=dxe86OWc2mI


import UIKit
import UserNotifications
import SwiftUI

extension Notification.Name {
    static let navigateToHome = Notification.Name("navigateToHome")
    static let navigateToProfile = Notification.Name("navigateToProfile")
}
class ViewController: UIViewController {
    @ObservedObject var aiViewModel = AIViewModel()
    @ObservedObject var firebaseViewModel = FirebaseViewModel()
    override func viewDidLoad() {
        print("hi")
        super.viewDidLoad()
        checkForPermissions()
    }
    func checkForPermissions() {
        let notifCenter = UNUserNotificationCenter.current()
        notifCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus{
                case.authorized:
                    self.dispatchNotification()
                case.denied:
                    return
                default:
                    return
            }
        
        }
    }
    func dispatchNotification() {
        print("Scheduling notification now with prompt")
        
        var prompt = ""
        Task {
            try await Task.sleep(for: .seconds(10))
            //await prompt = aiViewModel.getPromptOfTheDay()
            let body = "Write down your answer to this prompt: \(prompt)"
            UserDefaults.standard.set(prompt, forKey: "prompt")
            let isDaily = true
            let notificationCenter = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.categoryIdentifier = "JOURNAL_CATEGORY"
            
            let calendar = Calendar.current
            var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
            let hour = 20
            let minute = 57
            dateComponents.hour = hour
            dateComponents.minute = minute
            print("Notification will trigger at: \(calendar.date(from: dateComponents) ?? Date())")
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
            let request = UNNotificationRequest(identifier: "keepJournaling", content: content, trigger: trigger)
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["keepJournaling"] )
            do {
                try await notificationCenter.add(request)
            } catch {
                print("ugh")
            }
            
        }
    }
    
    

}

