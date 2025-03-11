//
//  FirebaseViewModel.swift
//  Keepsake
//
//  Created by Alec Hance on 2/18/25.
//

import Foundation
import Observation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

class FirebaseViewModel: ObservableObject {
    let db = Firestore.firestore()
    private lazy var functions: Functions = Functions.functions()
    var onSetupCompleted: ((FirebaseViewModel) -> Void)?
    
    @Published var searchedEntries: [JournalEntry] = []
    
    let auth = Auth.auth()
    static let vm = FirebaseViewModel()
    func configure() {
        self.onSetupCompleted?(self)
    }
    
    private struct QueryRequest: Codable {
      var query: String
      var limit: Int?
      var prefilters: [QueryFilter]?
    }

    private struct QueryFilter: Codable {
      var field: String
      var `operator`: String
      var value: String

    }
    
    private struct QueryResponse: Codable {
      var ids: [String]
    }
    
    
    private lazy var vectorSearchQueryCallable: Callable<QueryRequest, QueryResponse> = functions.httpsCallable("ext-firestore-vector-search-queryCallable")
    
    init() {
        auth.signIn(withEmail: "royankit11@gmail.com", password: "test123") { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                return
            }
        }
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
    
    func performVectorSearch(searchTerm: String, journal_id: String) async {
        do {
            let prefilters: [QueryFilter] = [QueryFilter(field: "journal_id", operator: "==", value: journal_id)]
            let queryRequest = QueryRequest(query: searchTerm,
                                                  limit: 2,
                                                  prefilters: prefilters)
            
            let result = try await vectorSearchQueryCallable(queryRequest)
            print(result)
            
            await fetchEntries(ids: result.ids)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchEntries(ids: [String]) async {
        do {
            var entries: [JournalEntry] = []
            for id in ids {
                let entry = try await fetchEntryById(id: id)
                if let entry = entry {
                    entries.append(entry)
                }
            }

            // Update the searchedEntries on the main thread
            await MainActor.run {
                searchedEntries = entries
            }
        } catch {
            print("Error fetching entries: \(error.localizedDescription)")
        }
    }
    
    private func fetchEntryById(id: String) async throws -> JournalEntry? {
        let docRef = db.collection("JOURNAL_ENTRIES").document(id)
        let document = try await docRef.getDocument()
        if document.exists {
            guard let data = document.data() else {
                print("Document data is nil")
                return nil
            }
            return JournalEntry(
                date: data["date"] as? String ?? "",
                title: data["title"] as? String ?? "",
                text: data["text"] as? String ?? "",
                summary: data["summary"] as? String ?? ""
            )
        } else {
            print("Document does not exist")
            return nil
        }
    }
}
