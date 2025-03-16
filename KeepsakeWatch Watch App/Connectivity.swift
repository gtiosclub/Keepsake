//
//  Connectivity.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/4/25.
//

//import WatchConnectivity
//
//class WatchSessionManager: NSObject, WCSessionDelegate {
//    static let shared = WatchSessionManager()
//    
//    override init() {
//        super.init()
//        setupWatchConnectivity()
//    }
//    
//    private func setupWatchConnectivity() {
//        if WCSession.isSupported() {
//            let session = WCSession.default
//            session.delegate = self
//            session.activate()
//        }
//    }
//    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
//        print("WCSession activation state: \(activationState)")
//        
////        // Ensure the session supports application context
////        if activationState == .activated {
////            if session.isPaired {
////                print("Watch is paired with iPhone")
////            }
////            
////            if session.isWatchAppInstalled {
////                print("Watch app is installed on paired iPhone")
////            }
////        }
////        
//        if let error = error {
//            print("WCSession activation error: \(error.localizedDescription)")
//        }
//    }
//    
////    func sessionDidBecomeInactive(_ session: WCSession) {
////        print("WCSession did become inactive")
////    }
////    
////    func sessionDidDeactivate(_ session: WCSession) {
////        print("WCSession did deactivate")
////        session.activate()
////    }
//    
//    // Method to transfer application context
//    func transferApplicationContext(data: [String: Any]) {
//        let session = WCSession.default
//        
//        guard session.isReachable else {
//            print("Watch is not reachable")
//            return
//        }
//        
//        do {
//            try session.updateApplicationContext(data)
//            print("Successfully transferred application context")
//        } catch {
//            print("Error transferring application context: \(error.localizedDescription)")
//        }
//    }
//    
//    // Send message method with more robust error handling
//    func sendMessageToPhone(data: [String: Any]) {
//        let session = WCSession.default
//
//        guard session.isReachable else {
//            print("Watch is not reachable")
//            transferApplicationContext(data: data)  // Fallback
//            return
//        }
//
//        if data.isEmpty {
//            print("Attempted to send empty data: \(data)")
//            return
//        }
//
//        session.sendMessage(data, replyHandler: { response in
//            print("Successfully sent message to iPhone: \(response)")
//        }, errorHandler: { error in
//            print("Error sending message to iPhone: \(error.localizedDescription)")
//            // Fallback to application context
//            self.transferApplicationContext(data: data)
//        })
//    }
//
//    // Handling received application context
//    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
//        print("Received application context: \(applicationContext)")
//    }
//    
//    // Optional method to handle received messages
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print("Received message on Watch: \(message)")
//    }
//}

//import Foundation
//import WatchConnectivity
//#if os(iOS)
//import FirebaseFirestore
//#endif
//enum ConnectivityKey: String {
//    case reminder
//}
//
//
//final class Connectivity: NSObject, WCSessionDelegate {
//    /// Connectivity singleton
//    static let shared = Connectivity()
//
//    /// Published item lists
//    @Published var reminder: Reminder
//
//    override private init() {
//       
//        self.reminder = Reminder(title: "Sample Reminder", date: Date(), body: "Test Reminder Body")
//        super.init()
//
//        WCSession.default.delegate = self
//        WCSession.default.activate()
//
//        // Make sure WCSession is supported
//#if !os(watchOS)
//        guard WCSession.isSupported() else { return }
//#endif
//
//        // Set WCSession's delegate to self and activate
//        
//        
//    }
//
//    // MARK: - Send/Receive Methods
//    
//
//    /// Send itemLists to companion
//    public func send(reminder: Reminder) {
//        // Check the session is activated
//        guard WCSession.default.activationState == .activated else {
//            print(":(")
//            return }
//        print("Activation State: \(WCSession.default.activationState.rawValue)")
//
//        // Check the companion's app is installed
//#if os(watchOS)
//        guard WCSession.default.isCompanionAppInstalled else {
//            print(":( :(")
//            return
//        }
//#else
//        guard WCSession.default.isWatchAppInstalled else { return }
//#endif
//
//        // Create the message using the itemLists' data
//        print("made it until here!")
//        do {
//                let data = try JSONEncoder().encode(reminder)
//                print("Encoded data: \(data.count) bytes")
//
//                let message: [String: Data] = [ConnectivityKey.reminder.rawValue: data]
//        
//            print("watchOS WCSession activation state: \(WCSession.default.activationState.rawValue)") // On watchOS side
//
//            WCSession.default.sendMessage(message, replyHandler: { response in
//                        print("Message sent successfully")
//                    }) { error in
//                        print("Error sending message: \(error.localizedDescription)")
//                }
//            } catch {
//                print("Error encoding reminder: \(error.localizedDescription)")
//            }
//        
//    }
//
//    // MARK: - WCSessionDelegate Methods
//
//    /// Receives the message from the companion
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print("📥 Received Message")
//        // Receive the data, decode it, and set it to itemLists
//        guard let data = message[ConnectivityKey.reminder.rawValue] as? Data,
//              let reminder = try? JSONDecoder().decode(Reminder.self, from: data) else { return }
//        self.reminder = reminder
//        print(self.reminder)
//#if os(iOS)
//        print("made it yayyyyyy YAY")
//        let db = Firestore.firestore()
//
//                // Save the reminder to Firebase
//                db.collection("users").document(reminder.id.uuidString).setData([
//                        "title": reminder.title,
//                        "date": reminder.date,
//                        "body": reminder.body
//                    ]) { error in
//                        if let error = error {
//                            print("Error saving reminder to Firebase: \(error.localizedDescription)")
//                        } else {
//                            print("Reminder saved to Firebase successfully.")
//                        }
//                    }
//#endif
//    }
//
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) { }
//
//#if os(iOS)
//    func sessionDidBecomeInactive(_ session: WCSession) { }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//        // If the watch has been switched, reactivate their session on the new watch
//        WCSession.default.activate()
//    }
//#endif
//}




//import Foundation
//import WatchConnectivity
//
//final class Connectivity: NSObject, WCSessionDelegate {
//    static let shared = Connectivity()
//
//    @Published var reminders: [Reminder] = []
//
//    override private init() {
//        super.init()
//        #if !os(watchOS)
//        guard WCSession.isSupported() else { return }
//        #endif
//        WCSession.default.delegate = self
//        WCSession.default.activate()
//    }
//
//    public func send(reminder: Reminder) {
//        guard WCSession.default.activationState == .activated else { return }
//        #if os(watchOS)
//        guard WCSession.default.isCompanionAppInstalled else { return }
//        #else
//        guard WCSession.default.isWatchAppInstalled else { return }
//        #endif
//        
//        guard let data = try? JSONEncoder().encode(reminder) else { return }
//
//        let message: [String: Data] = [
//            "reminder": data
//        ]
//
//        WCSession.default.sendMessage(message, replyHandler: nil) { error in
//            print("Error sending data: \(error.localizedDescription)")
//        }
//    }
//
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        guard let data = message["reminder"] as? Data,
//              let reminder = try? JSONDecoder().decode(Reminder.self, from: data) else { return }
//        self.reminders.append(reminder)
//    }
//
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) { }
//
//    #if os(iOS)
//    func sessionDidBecomeInactive(_ session: WCSession) { }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//        WCSession.default.activate()
//    }
//    #endif
//}



import Foundation
import WatchConnectivity

final class Connectivity: NSObject, WCSessionDelegate {
    static let shared = Connectivity()

    @Published var reminders: [Reminder] = []

    override private init() {
        super.init()
        loadReminders()
        #if !os(watchOS)
        guard WCSession.isSupported() else { return }
        #endif
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "reminders"),
           let savedReminders = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = savedReminders
        }
    }

    func saveReminders() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: "reminders")
        }
    }

    public func send(reminder: Reminder) {
        guard WCSession.default.activationState == .activated else { return }
        #if os(watchOS)
        guard WCSession.default.isCompanionAppInstalled else { return }
        #else
        guard WCSession.default.isWatchAppInstalled else { return }
        #endif
        
        guard let data = try? JSONEncoder().encode(reminder) else { return }

        let message: [String: Data] = [
            "reminder": data
        ]

        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending data: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let data = message["reminder"] as? Data,
              let reminder = try? JSONDecoder().decode(Reminder.self, from: data) else { return }
        reminders.append(reminder)
        saveReminders()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) { }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
