//
//  Connectivity.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/4/25.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("WCSession activation state: \(activationState)")
        
//        // Ensure the session supports application context
//        if activationState == .activated {
//            if session.isPaired {
//                print("Watch is paired with iPhone")
//            }
//            
//            if session.isWatchAppInstalled {
//                print("Watch app is installed on paired iPhone")
//            }
//        }
//        
        if let error = error {
            print("WCSession activation error: \(error.localizedDescription)")
        }
    }
    
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("WCSession did become inactive")
//    }
//    
//    func sessionDidDeactivate(_ session: WCSession) {
//        print("WCSession did deactivate")
//        session.activate()
//    }
    
    // Method to transfer application context
    func transferApplicationContext(data: [String: Any]) {
        let session = WCSession.default
        
        guard session.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        do {
            try session.updateApplicationContext(data)
            print("Successfully transferred application context")
        } catch {
            print("Error transferring application context: \(error.localizedDescription)")
        }
    }
    
    // Send message method with more robust error handling
    func sendMessageToPhone(data: [String: Any]) {
        let session = WCSession.default

        guard session.isReachable else {
            print("Watch is not reachable")
            transferApplicationContext(data: data)  // Fallback
            return
        }

        if data.isEmpty {
            print("Attempted to send empty data: \(data)")
            return
        }

        session.sendMessage(data, replyHandler: { response in
            print("Successfully sent message to iPhone: \(response)")
        }, errorHandler: { error in
            print("Error sending message to iPhone: \(error.localizedDescription)")
            // Fallback to application context
            self.transferApplicationContext(data: data)
        })
    }

    // Handling received application context
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Received application context: \(applicationContext)")
    }
    
    // Optional method to handle received messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message on Watch: \(message)")
    }
}
