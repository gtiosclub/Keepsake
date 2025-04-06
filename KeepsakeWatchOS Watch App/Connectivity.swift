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
    //var authViewModel: AuthViewModel?
    #endif
    @Published var reminders: [Reminder] = []
    @Published var audioFiles: [String] = []
    @Published var audioUniqueId: String?
    @Published var remindersWithAudio: [(reminder: Reminder, audioUrl: String)] = []
    override private init() {
        super.init()
        loadReminders()
        #if !os(watchOS)
        guard WCSession.isSupported() else { return }
        print(firebaseVM.currentUser?.username)
        #endif
        
        WCSession.default.delegate = self
        WCSession.default.activate()
        print("WCSession activated")
    }
#if os(iOS)
    
//    func setAuthViewModel(_ viewModel: AuthViewModel) {
//        self.authViewModel = viewModel
//    }
#endif
    private func loadReminders() {
        #if os(watchOS)
            print(" watch reached")
        #endif
    #if os(iOS)
        print("ios reached")
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
    public func requestAudioFiles() {
        print("files requested")
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["requesting audio files": true], replyHandler: { response in
                //phone gives response then:
                if let audioFilesUrl = response["audioFilesUrl"] as? [String] {
                    DispatchQueue.main.async {
                        self.audioFiles = audioFilesUrl
                    }
                }
            })
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
    
    func updateIsCheckedInFirestore(reminderId: String, isChecked: Bool) {
#if os(iOS)
        let reminderRef = firebaseVM.db.collection("reminders").document(reminderId)
            reminderRef.updateData([
                "isChecked": isChecked
            ]) { error in
                if let error = error {
                    print("error updating document: \(error.localizedDescription)")
                } else {
                    print("successfully updated isChecked for reminder with ID \(reminderId)")
                }
            }
#endif
        }
    
    func fetchAudioFiles() async {
        print("Starting audio files fetch")
        #if os(iOS)
        guard let uid = firebaseVM.currentUser?.id else {
            print("No uid found")
            return
        }
        print("this is the uid: \(uid)")
        
        
        let storageRef = Storage.storage().reference().child("audio").child(uid)
        
        let listTask = storageRef.list(maxResults: 50) { (result, error) in
            if let error = error {
                print("error getting the audio files: \(error.localizedDescription)")
                return
            }
            guard let items = result?.items, !items.isEmpty else {
                print("there isn't any audio files yet: \(uid)")
                return
            }
            
            print("audio file count: \(items.count)")
            var audioFilesUrl: [String] = []
            let dispatchGroup = DispatchGroup()
            
            let db = Firestore.firestore()
            var reminders: [Reminder] = []
            
            for item in items {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    
                    
                    if let error = error {
                        print("error with download url \(item.name): \(error.localizedDescription)")
                    } else if let url = url {
                        print("found the audio file: \(url.absoluteString)")
                        audioFilesUrl.append(url.absoluteString)
                        
                        let audioUniqueId = item.name
                        
                        db.collection("reminders").document(audioUniqueId).getDocument { (document, error) in
                            if let error = error {
                                print("Error getting reminder: \(error.localizedDescription)")
                            } else if let document = document, document.exists {
                                // Parse reminder data here
                                print("reminder found")
                                if let reminder = try? document.data(as: Reminder.self) {
                                    self.remindersWithAudio.append((reminder, url.absoluteString))
                                    print("Found reminder for audioUniqueId: \(audioUniqueId)")
                                    scheduleReminderNotification(for: reminder)
                                }
                            } else {
                                print("No reminder found for \(audioUniqueId)")
                            }
                            
                        }
                        dispatchGroup.leave()
                        
                    }
                }
            }
            
            
            dispatchGroup.notify(queue: .main) {
                print("audio processed")
                self.audioFiles = audioFilesUrl
                self.remindersWithAudio = self.remindersWithAudio
                if WCSession.default.isReachable {
                    WCSession.default.sendMessage(["audio files": audioFilesUrl], replyHandler: nil) { error in
                        print("error: \(error.localizedDescription)")
                    }
                    print("sending audio to watch")
                } else {
                    print("the watch disappeared ಠ_ಠ")
                }
                
                    

                
            }
            
            
        }
        #endif
        print("after ios stuff")
        
    }

    
    func deleteReminder(reminderId: String) {
        #if os(iOS)
        firebaseVM.db.collection("reminders").document(reminderId).delete() { error in
            if let error = error {
                print("error removing the reminder \(error.localizedDescription)")
            } else {
                print("reminder is deleted")
            }
        }
        let storageRefForAudio = Storage.storage().reference().child("audio").child(firebaseVM.currentUser!.id).child(reminderId)
        storageRefForAudio.delete() { error in
            if let error = error {
                print("error deleting audio \(error.localizedDescription)")
            } else {
                print("audio has been deleted")
            }
        }
        #endif
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
        guard let uid = firebaseVM.currentUser?.id else {
            print("no uid")
            return
        }
        audioUniqueId = "\(UUID()).uuidString.m4a"
        let storageRef = Storage.storage().reference().child("audio/\(uid)/\(audioUniqueId)")
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
        #if os(iOS)
        if let _ = message["requesting audio files"] as? Bool {
            Task {
                print("hi")
                await fetchAudioFiles()
            }
        }
        #endif
        if let audioFilesUrl = message["audio files"] as? [String] {
                DispatchQueue.main.async {
                    self.audioFiles = audioFilesUrl
                    print("Audio files received: \(audioFilesUrl)")
                }
        }
        
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
        if firebaseVM.userSession != nil {
            uid = firebaseVM.currentUser!.id
            } else {
                print("no user")
            }
            
            db.collection("reminders").addDocument(data: ["uid": uid!, "date": reminder.date]){ error in
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

