//
//  PhoneSessionManager.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/4/25.
//

//import WatchConnectivity
//import FirebaseStorage
//import FirebaseFirestore
//
//class PhoneSessionManager: NSObject, WCSessionDelegate {
//    
//    
//    static let shared = PhoneSessionManager()
//    
//    override init() {
//        super.init()
//        setupWatchConnectivity()
//    }
//    private func setupWatchConnectivity() {
//            if WCSession.isSupported() {
//                let session = WCSession.default
//                session.delegate = self
//                session.activate()
//            }
//    }
//    // Handle the message received from watchOS
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
//            switch activationState {
//            case .activated:
//                print("WCSession is activated")
//            case .inactive:
//                print("WCSession is inactive")
//            case .notActivated:
//                print("WCSession is not activated")
//            @unknown default:
//                print("WCSession is in an unknown state")
//            }
//            
//            if let error = error {
//                print("WCSession activation error: \(error.localizedDescription)")
//            }
//        }
//    func sessionDidBecomeInactive(_ session: WCSession) {
//            print("WCSession did become inactive")
//        }
//        
//        func sessionDidDeactivate(_ session: WCSession) {
//            print("WCSession did deactivate")
//            // Reactivate the session
//            session.activate()
//        }
//    
//    // Upload audio file to Firebase Storage
//    private func uploadAudioToFirebaseStorage(fileURL: URL, completion: @escaping (URL?) -> Void) {
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//        let audioRef = storageRef.child("audioFiles/\(fileURL.lastPathComponent)")
//        
//        audioRef.putFile(from: fileURL, metadata: nil) { metadata, error in
//            if let error = error {
//                print("Error uploading audio: \(error)")
//                completion(nil)
//            } else {
//                audioRef.downloadURL { url, error in
//                    if let error = error {
//                        print("Error retrieving download URL: \(error)")
//                        completion(nil)
//                    } else {
//                        completion(url)
//                    }
//                }
//            }
//        }
//    }
//    
//    // Save the reminder data to Firestore
//    func sendReminderToPhone(reminderData: [String: Any]) {
//            let session = WCSession.default
//            
//            guard session.isReachable else {
//                print("Watch is not reachable")
//                return
//            }
//            
//            session.sendMessage(reminderData, replyHandler: { response in
//                print("Successfully sent reminder data to iPhone")
//            }, errorHandler: { error in
//                print("Failed to send message: \(error.localizedDescription)")
//            })
//    }
//}
