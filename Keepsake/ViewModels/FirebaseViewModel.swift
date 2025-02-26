//
//  FirebaseViewModel.swift
//  Keepsake
//
//  Created by Alec Hance on 2/18/25.
//

import Foundation
import FirebaseFirestore

class FirebaseViewModel: ObservableObject {
    let db = Firestore.firestore()
    var onSetupCompleted: ((FirebaseViewModel) -> Void)?
    
    static let vm = FirebaseViewModel()
    func configure() {
        self.onSetupCompleted?(self)
    }
    
    func testRead() async -> Int {
        let docRef = db.collection("USERS").document("Test")
        
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let id = document.data()?["id"] as? Int else {
                    print("id is not an int")
                    return -1
                }
                print("completed")
                return id
            } else {
                print("document doesn't exist")
                return -1
            }
        } catch {
            print("message")
            return -1
        }
    }
    
    // Add a Journal Model into Firebase
    func addJournal(journal: Journal) async -> Bool {
        let docRef = db.collection("USERS").document("Test")
        var data: [String: Any] = [:]
        data["id"] = journal.id
        data["title"] = journal.title
        data["entries"] = journal.entries
        do {
            try await docRef.setData(data)
        } catch {
            
        }
    }
    
    // Get a Journal Document from Firebase and load it into a Journal Model
    
    
    // Add an entry into Firebase
    
}
