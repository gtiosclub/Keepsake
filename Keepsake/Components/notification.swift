//
//  notification.swift
//  Keepsake
//
//  Created by Nitya Potti on 4/5/25.
//

//Tutorial used: https://www.youtube.com/watch?v=dxe86OWc2mI


import UIKit
import UserNotifications

class ViewController: UIViewController {
    var aiViewModel = AIViewModel()
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
        let title = "Keep Journaling!"
        var prompt = ""
        Task {
            await prompt = aiViewModel.getPromptOfTheDay()
        }
        let body = "Write down your answer to this prompt: \(prompt)"
        UserDefaults.standard.set(prompt, forKey: "pendingPrompt")
        let isDaily = true
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent() //to specify title and message for an alert
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        let hour = 12
        let minute = 0
        dateComponents.hour = hour
        dateComponents.minute = minute
        print("Notification will trigger at: \(calendar.date(from: dateComponents) ?? Date())")
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: "keepJournaling", content: content, trigger: trigger)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["keepJournaling"] )
        notificationCenter.add(request)
        
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

}

