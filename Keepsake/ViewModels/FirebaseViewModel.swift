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
        let journal_reference = db.collection("JOURNALS").document(journal.id.uuidString)
        do {
            let journalData = journal.toDictionary()
            try await journal_reference.setData(journalData)
            return true
        } catch {
            print("Error adding journal: \(error.localizedDescription)")
            return false
        }
    }
    
    
    func addJournalShelf(journalShelf: JournalShelf) async -> Bool {
        let journal_reference = db.collection("JOURNAL_SHELVES").document(journalShelf.id.uuidString)
        do {
            // Chains together each Model's "toDictionary()" method for simplicity in code and scalability in editing each Model
            let journalShelfData = journalShelf.toDictionary()
            try await journal_reference.setData(journalShelfData)
            return true
        } catch {
            print("Error adding Journal Shelf: \(error.localizedDescription)")
            return false
        }
    }
    
    // Get a JournalShelf Document from Firebase and load it into a Journal Model
    func getJournalShelfFromFirebase(id: String) async -> JournalShelf? {
        let journalReference = db.collection("JOURNAL_SHELVES").document(id)
        do {
            let document = try await journalReference.getDocument()
            if let data = document.data() {
                // Chains together each Model's "fromDictionary()" method for simplicity in code and scalability in editing each Model
                return JournalShelf.fromDictionary(data)
            } else {
                print("No document found")
                return nil
            }
        } catch {
            print("Error fetching Journal Shelf: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Add an entry into Firebase
    func getAPIKeys() async throws -> [String: String] {
        var apimap: [String: String] = [:]
        
        let getdocs = try await db.collection("API_KEYS").getDocuments()
        
        for doc in getdocs.documents {
            if let key = doc.data()["key"] as? String {
                apimap[doc.documentID] = key
            }
        }
        
        return apimap
    }
}
