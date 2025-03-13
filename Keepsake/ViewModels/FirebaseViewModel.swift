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
    
    /****######################################################################################
    JOURNALS
     #########################################################################################**/
    
    // Add a Journal Model into Firebase
    func addJournal(journal: Journal, journalShelfID: UUID) async -> Bool {
        let journal_reference = db.collection("JOURNALS").document(journal.id.uuidString)
        do {
            let journalData = journal.toDictionary()
            try await journal_reference.setData(journalData)
            
            try await db.collection("JOURNAL_SHELVES").document(journalShelfID.uuidString).updateData([
                "journals": FieldValue.arrayUnion([journal.id.uuidString])
            ])
            
            return true
        } catch {
            print("Error adding journal: \(error.localizedDescription)")
            return false
        }
    }
    
    func getJournalFromID(id: String) async -> Journal? {
        let journalReference = db.collection("JOURNALS").document(id)
        
        do {
            let document = try await journalReference.getDocument()
            if let dict = document.data() {
                let name = dict["name"] as? String ?? ""
                let idString = dict["id"] as? String ?? ""
                let id = UUID(uuidString: idString) ?? UUID()
                let createdDate = dict["createdDate"] as? String ?? ""
                let category = dict["category"] as? String ?? ""
                let isSaved = dict["isSaved"] as? Bool ?? true
                let isShared = dict["isShared"] as? Bool ?? false
                let templateDict = dict["template"] as? [String: Any] ?? [:]
                let template = Template.fromDictionary(templateDict) ?? Template()
                let pagesArray = dict["pages"] as? [String: [String]] ?? [:]
                let currentPage = dict["currentPage"] as? Int ?? 0
                
                var journalPages: [JournalPage] = []
                
                for (page, entryIDs) in pagesArray {
                    let num = page
                    let entryCount = entryIDs.count
                    var journalEntries: [JournalEntry] = []
                    
                    for entryID in entryIDs {
                        let entry = await getJournalEntryFromID(id: entryID)
                        if let entry = entry {
                            journalEntries.append(entry)
                        }
                    }
                    
                    journalPages.append(JournalPage(number: Int(num) ?? 0, entries: journalEntries, realEntryCount: entryCount))
                }
                return Journal(name: name, id: id, createdDate: createdDate, category: category, isSaved: isSaved, isShared: isShared, template: template, pages: journalPages, currentPage: currentPage)
                
            } else {
                print("No document found")
                return nil
            }
        } catch {
            print("Error fetching Journal Shelf: \(error.localizedDescription)")
            return nil
        }
    }
    //#########################################################################################
    
    /****######################################################################################
    JOURNAL SHELF
     #########################################################################################**/
    
    func addJournalShelf(journalShelf: JournalShelf) async -> Bool {
        let journalShelfReference = db.collection("JOURNAL_SHELVES").document(journalShelf.id.uuidString)
        do {
            // Chains together each Model's "toDictionary()" method for simplicity in code and scalability in editing each Model
            let journalShelfData = journalShelf.toDictionary()
            try await journalShelfReference.setData(journalShelfData)
            return true
        } catch {
            print("Error adding Journal Shelf: \(error.localizedDescription)")
            return false
        }
    }
    
    // Get a JournalShelf Document from Firebase and load it into a Journal Model
    func getJournalShelfFromID(id: String) async -> JournalShelf? {
        let journalShelfReference = db.collection("JOURNAL_SHELVES").document(id)
        do {
            let document = try await journalShelfReference.getDocument()
            if let data = document.data() {
                let name = data["name"] as? String ?? ""
                let idString = data["id"] as? String ?? ""
                let id = UUID(uuidString: idString) ?? UUID()
                let journalIDs = data["journals"] as? [String] ?? []
                
                var arrJournals: [Journal] = []
                
                for journalId in journalIDs {
                    let journal = await getJournalFromID(id: journalId)
                    if let journal = journal {
                        arrJournals.append(journal)
                    }
                }
                return JournalShelf(name: name, id: id, journals: arrJournals)
                
            } else {
                print("No document found")
                return nil
            }
        } catch {
            print("Error fetching Journal Shelf: \(error.localizedDescription)")
            return nil
        }
    }
    
    //#########################################################################################
    
    /****######################################################################################
    JOURNAL ENTRY
     #########################################################################################**/
    
    func addJournalEntry(journalEntry: JournalEntry, journalID: UUID, pageNumber: Int) async -> Bool {
        let journal_entry_reference = db.collection("JOURNAL_ENTRIES").document(journalEntry.id.uuidString)
        do {
            let journalEntryData = journalEntry.toDictionary(journalID: journalID)
            try await journal_entry_reference.setData(journalEntryData)
            
            try await db.collection("JOURNALS").document(journalID.uuidString).updateData([
                "pages.\(pageNumber)": FieldValue.arrayUnion([journalEntry.id.uuidString])
            ])
            
            return true
        } catch {
            print("Error adding journal: \(error.localizedDescription)")
            return false
        }
    }
    
    func getJournalEntryFromID(id: String) async -> JournalEntry? {
        let journalEntryReference = db.collection("JOURNAL_ENTRIES").document(id)
        
        do {
            let document = try await journalEntryReference.getDocument()
            if let dict = document.data() {
                return JournalEntry.fromDictionary(dict)
            } else {
                print("No document found")
                return nil
            }
        } catch {
            print("Error fetching Journal Shelf: \(error.localizedDescription)")
            return nil
        }
    }
    
    //#########################################################################################
    
    
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
        var entries: [JournalEntry] = []
        for id in ids {
            let entry = await getJournalEntryFromID(id: id)
            if let entry = entry {
                entries.append(entry)
            }
        }

        // Update the searchedEntries on the main thread
        await MainActor.run {
            searchedEntries = entries
        }
    }
    
}
