//
//  Connectivity.swift
//  Keepsake
//
//  Created by Nitya Potti on 3/29/25.
//

import Foundation
import WatchConnectivity
#if os(iOS)
import FirebaseFirestore
import FirebaseStorage
#endif
import SwiftUI
final class Connectivity: NSObject, WCSessionDelegate {
    
    static let shared = Connectivity()
    #if os(iOS)
    @Published private var firebaseVM = FirebaseViewModel()
    var authViewModel: AuthViewModel?
    #endif
    @Published var reminders: [Reminder] = []

    override private init() {
        super.init()
        loadReminders()
        #if !os(watchOS)
        guard WCSession.isSupported() else { return }
        #endif
        WCSession.default.delegate = self
        WCSession.default.activate()
        print("WCSession activated")
    }
#if os(iOS)
    
    func setAuthViewModel(_ viewModel: AuthViewModel) {
        self.authViewModel = viewModel
    }
#endif
    private func loadReminders() {
        #if os(watchOS)
            print(" watch reached")
        #endif
    #if os(iOS)
        print(" iOS reached")
#endif
        if let data = UserDefaults.standard.data(forKey: "reminders"),
           let savedReminders = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = savedReminders
        }
#if os(watchOS)
    print(" done loading watch")
#endif
#if os(iOS)
        print(" done loading iOS")
#endif
    }
    
    
    func saveReminders() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: "reminders")
        }
    }

    public func send(reminder: Reminder) {
        print("sending")
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
        print("sent")
    }
    public func send(audioFileUrl: URL) {
        print("sending audio")
        WCSession.default.transferFile(audioFileUrl, metadata: nil)
        print("Audio file sent: \(audioFileUrl)")
    }
    func fetchAudioFiles() {
        #if os(iOS)
        guard let uid = authViewModel?.currentUser?.id else {
            print("No UID found")
            return
        }

        let storageRef = Storage.storage().reference().child("audio/\(uid)/")
        
        // List all files in the audio folder for the current user
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error fetching audio files: \(error.localizedDescription)")
                return
            }

            var audioFiles: [String] = [] // Array to hold audio file download URLs
            let dispatchGroup = DispatchGroup()

            for item in result.items {
                dispatchGroup.enter()

                // Get the download URL for each audio file
                item.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL for file: \(error.localizedDescription)")
                    } else if let url = url {
                        audioFiles.append(url.absoluteString) // Store the download URL
                    }
                    dispatchGroup.leave()
                }
            }

            // Once all URLs have been fetched, update reminders with the corresponding URLs
            dispatchGroup.notify(queue: .main) {
                self.updateRemindersWithAudioFiles(audioFiles)
            }
        }
        #endif
    }

    func updateRemindersWithAudioFiles(_ audioFiles: [String]) {
        for (index, reminder) in reminders.enumerated() {
            // Here, you can match reminders to audio files based on some criteria
            // For simplicity, just associate an audio file to each reminder in a 1-to-1 fashion
            if index < audioFiles.count {
                reminders[index].audioFileURL = audioFiles[index]
            }
        }
        // You can then save these reminders again to UserDefaults if needed
        saveReminders()
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(file.fileURL.lastPathComponent)
        do {
            try FileManager.default.moveItem(at: file.fileURL, to: destinationURL)
            print("received audio at \(destinationURL)")
            uploadAudioToFirebase(fileURL: destinationURL)
        } catch {
            print("Error moving the file :( \(error.localizedDescription)")
        }
    }
    func uploadAudioToFirebase(fileURL: URL) {
        #if os(iOS)
        guard let uid = authViewModel?.currentUser?.id else {
            print("no uid")
            return
        }
        let storageRef = Storage.storage().reference().child("audio/\(uid)/\(UUID()).uuidString.m4a")
        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                print("There's an error uploading the file: \(error.localizedDescription)")
                return
            }
            print("Upload is successful!! :)")
            
            //Idk if this deletes from the phone local storage or watch local storage or both?
            try? FileManager.default.removeItem(at: fileURL)
            
        }
        #endif
        
        
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("recieved")
        guard let data = message["reminder"] as? Data,
              let reminder = try? JSONDecoder().decode(Reminder.self, from: data) else { return }
        
        DispatchQueue.main.async {
            self.reminders.append(reminder)
            self.saveReminders()
            print("Reminder added: \(reminder)")
        }
        #if os(iOS)
            let db = firebaseVM.db
            var uid: String?
        if authViewModel?.userSession != nil {
            uid = authViewModel?.currentUser!.id
            } else {
                print("no user")
            }
            
            db.collection("reminders").addDocument(data: ["uid": uid!, "title": reminder.title, "date": reminder.date]){ error in
                if let error = error {
                    print("Error saving reminder to Firebase: \(error.localizedDescription)")
                } else {
                    print("Reminder saved to Firebase successfully.")
                }
            }
        #endif
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) { }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}

