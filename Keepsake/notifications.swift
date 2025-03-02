//
//  notifications.swift
//  Keepsake
//
//  Created by Nitya Potti on 3/2/25.
//
//Tutorial used: https://www.youtube.com/watch?v=dxe86OWc2mI
//getting document count: https://stackoverflow.com/questions/70011334/count-documents-from-firestore-without-counting-as-reads-swift

import UIKit
import UserNotifications
import FirebaseFirestore

class ViewController: UIViewController {
//    var aiViewModel: AIViewModel
//    var firebaseModel: FirebaseViewModel
//    required init?(coder: NSCoder) {
//            // I have to include this for UIViewController.
//            self.aiViewModel = AIViewModel()
//            self.firebaseModel = FirebaseViewModel()
//            super.init(coder: coder)
//    }
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
        let body = "Leave a daily voice memo or set a reminder!"
//        let db = firebaseModel.db
////        db.collection("journals").getDocuments {snapshot, _ in
////            guard let journals = snapshot?.documents else {
////                return
////            }
////        }
//        let collectionReference = db.collection("journals")
//        collectionReference.order(by: "modifiedAt", descending: true).limit(to: 1)
//        //let randomJournal = Int.random(in: 0..<journals.count)
//        collectionReference.getDocuments { snapshot, _ in
//            guard let journals = snapshot?.documents else {
//                return
//            }
//        }
//        let prompt = aiViewModel.getSmartPrompts(journal: journals[0])
        
        let isDaily = true
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent() //to specify title and message for an alert
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        let hour = 18
        let minute = 15
        dateComponents.hour = hour
        dateComponents.minute = minute
        print("Notification will trigger at: \(calendar.date(from: dateComponents) ?? Date())")
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: "keepJournaling", content: content, trigger: trigger)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["keepJournaling"] )
        notificationCenter.add(request)
        
    }
}
