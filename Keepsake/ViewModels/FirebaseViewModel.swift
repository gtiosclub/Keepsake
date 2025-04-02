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
import FirebaseStorage

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}

class FirebaseViewModel: ObservableObject {
    let db = Firestore.firestore()
    private lazy var functions: Functions = Functions.functions()
    var onSetupCompleted: ((FirebaseViewModel) -> Void)?
    
    @Published var searchedEntries: [JournalEntry] = []
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
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
    
//    init() {
//        auth.signIn(withEmail: "royankit11@gmail.com", password: "test123") { [weak self] authResult, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                return
//            }
//        }
//    }
    
    init() {
        self.userSession = auth.currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        
            let result = try await auth.signIn(withEmail: email, password: password)
            await MainActor.run {
                self.userSession = result.user
            }
               
            await fetchUser()
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let initialShelf = JournalShelf(name: "Initial Shelf", id: UUID(), journals: [])
            self.userSession = result.user
            let user = User(id: result.user.uid, name: fullname, username: email, journalShelves: [], scrapbookShelves: [], savedTemplates: [], friends: [], lastUsedShelfID: initialShelf.id, isJournalLastUsed: true)
            let userData: [String: Any] = [
                "uid": user.id,
                "name": user.name,
                "username": user.username,
                "journalShelves": ["\(initialShelf.id)"],
                "scrapbookShelves": [],
                "templates": [],
                "friends": [],
                "lastUsedShelfId": "\(initialShelf.id)",
                "isJournalLastUsed": true
            ]
            try await Firestore.firestore().collection("USERS").document(user.id).setData(userData)
            await self.addJournalShelf(journalShelf: initialShelf, userID: user.id)
            await fetchUser()
            
        } catch {
            print("error :( \(error.localizedDescription)")
        }
    }
    func signOut() {
        do {
            try auth.signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            
        }
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = auth.currentUser?.uid else {return}
        
        guard let snapshot = try? await Firestore.firestore().collection("USERS").document(uid).getDocument() else { return }
        if snapshot.exists {
            // Manually extract data from the snapshot
            if let uid = snapshot.get("uid") as? String,
               let name = snapshot.get("name") as? String,
               let username = snapshot.get("username") as? String,
               let journalShelfIds = snapshot.get("journalShelves") as? [String],
               let scrapbookShelfIds = snapshot.get("scrapbookShelves") as? [String],
               let templates = snapshot.get("templates") as? [String],
               let friends = snapshot.get("friends") as? [String],
               let lastUsed = snapshot.get("lastUsedShelfId") as? String,
               let isJournalLastUsed = snapshot.get("isJournalLastUsed") as? Bool
            {
                var journalShelves: [JournalShelf] = []
                for astr in journalShelfIds {
                    let shelf = await getJournalShelfFromID(id: astr)!
                    journalShelves.append(shelf)
                }
                let lastUsedID: UUID
                if let temp = UUID(uuidString: lastUsed) {
                    lastUsedID = temp
                } else {
                    print("Error getting last used ID")
                    lastUsedID = UUID()
                }
                var imageDict: [String: UIImage] = [:]
                for shelf in journalShelves {
                    for journal in shelf.journals {
                        for page in journal.pages {
                            for entry in page.entries {
                                for url in entry.images {
                                    if let image = await getImageFromURL(urlString: url) {
                                        imageDict[url] = image
                                    }
                                }
                            }
                        }
                    }
                }
                print(imageDict)
                let user = User(id: uid, name: name, username: username, journalShelves: journalShelves, scrapbookShelves: [], savedTemplates: [], friends: friends, lastUsedShelfID: lastUsedID, isJournalLastUsed: isJournalLastUsed, images: imageDict)
                
                // Assign the user object to currentUser
                await MainActor.run {
                                self.currentUser = user
                }
                
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
    
    func deleteJournal(journalID: String, journalShelfID: UUID) async {
        var allEntryIds: [String] = []
        // Delete all entries
        do {
            let document = try await db.collection("JOURNALS").document(journalID).getDocument()
            if let data = document.data(),
               let pages = data["pages"] as? [String: [String]] {
                for (page, entry) in pages {
                    allEntryIds.append(contentsOf: entry)
                }
            } else {
                print("Couldn't get all page entries")
            }
            print(allEntryIds)
            for entry in allEntryIds {
                if let uuid = UUID(uuidString: entry) {
                    await removeJournalEntry(entryID: uuid)
                } else {
                    print("Invalid UUID string: \(entry)")
                }
            }
        } catch {
            print("error deleting entries")
            return
        }
        // Remove Journal Id from journal Shelf
        let documentRef = db.collection("JOURNAL_SHELVES").document(journalShelfID.uuidString)
        do {
            try await documentRef.updateData(["journals": FieldValue.arrayRemove([journalID])])
        } catch {
            print("could not remove journal ID from shelf")
            return
        }
        //Remove Journal
        do {
            try await db.collection("JOURNALS").document(journalID).delete()
        } catch {
            print("Error removing document: \(error)")
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
                    switch journalEntries.count {
                    case 0: journalEntries = [JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()]
                    case 1: journalEntries = [journalEntries[0], JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()]
                    case 2: journalEntries = [journalEntries[0], JournalEntry(), JournalEntry(), JournalEntry(), journalEntries[1], JournalEntry(), JournalEntry(), JournalEntry()]
                    case 3: journalEntries = [journalEntries[0], journalEntries[1], JournalEntry(), JournalEntry(), journalEntries[2], JournalEntry(), JournalEntry(), JournalEntry()]
                    case 4: journalEntries = [journalEntries[0], journalEntries[1], JournalEntry(), journalEntries[2], journalEntries[3], JournalEntry(), JournalEntry(), JournalEntry()]
                    case 5: journalEntries = [journalEntries[0], journalEntries[1], JournalEntry(), journalEntries[2], journalEntries[3], JournalEntry(), journalEntries[4], JournalEntry()]
                    case 6: journalEntries = [journalEntries[0], journalEntries[1], JournalEntry(), journalEntries[2], journalEntries[3], JournalEntry(), journalEntries[4], journalEntries[5]]
                    case 7: journalEntries = [journalEntries[0], journalEntries[1], JournalEntry(), journalEntries[2], journalEntries[3], journalEntries[4], journalEntries[5], journalEntries[6]]
                    default: journalEntries = [journalEntries[0], journalEntries[1], journalEntries[2], journalEntries[3], journalEntries[4], journalEntries[5], journalEntries[6], journalEntries[7]]
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
    
    func addJournalShelf(journalShelf: JournalShelf, userID: String) async -> Bool {
        let journalShelfReference = db.collection("JOURNAL_SHELVES").document(journalShelf.id.uuidString)
        do {
            // Chains together each Model's "toDictionary()" method for simplicity in code and scalability in editing each Model
            let journalShelfData = journalShelf.toDictionary()
            try await journalShelfReference.setData(journalShelfData)
            
            try await db.collection("USERS").document(userID).updateData([
                "journalShelves": FieldValue.arrayUnion([journalShelf.id.uuidString])
            ])
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
    
    func updateUserLastUsedShelf(user: User) async {
        let userRef = db.collection("USERS").document(user.id)
        do {
            try await userRef.updateData([
                "lastUsedShelfId": user.lastUsedShelfID.uuidString,
                "isJournalLastUsed": user.isJournalLastUsed
            ])
        } catch {
            print("error setting last used shelf")
        }
    }
    
    func updateShelfName(shelfID: UUID, newName: String) async {
        let shelfRef = db.collection("JOURNAL_SHELVES").document(shelfID.uuidString)
        do {
            try await shelfRef.updateData([
                "name": newName
            ])
        } catch {
            print("error renaming shelf")
        }
    }
    
    func deleteShelf(shelfID: UUID, userID: String) async {
        // Delete all journals
        do {
            let document = try await db.collection("JOURNAL_SHELVES").document(shelfID.uuidString).getDocument()
            if let data = document.data(),
               let journals = data["journals"] as? [String] {
                for journal in journals {
                    await deleteJournal(journalID: journal, journalShelfID: shelfID)
                }
            } else {
                print("Error getting journals to delete")
            }
        } catch {
            print("error deleting journals from shelf")
            return
        }
        // Remove shelf Id from user shelves
        let documentRef = db.collection("USERS").document(userID)
        do {
            try await documentRef.updateData(["journalShelves": FieldValue.arrayRemove([shelfID.uuidString])])
        } catch {
            print("could not remove shelf from user")
            return
        }
        //Remove Journal
        do {
            try await db.collection("JOURNAL_SHELVES").document(shelfID.uuidString).delete()
        } catch {
            print("Error removing shelf: \(error)")
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
                "pages.\(pageNumber + 1)": FieldValue.arrayUnion([journalEntry.id.uuidString])
            ])
            
            return true
        } catch {
            print("Error adding journal: \(error.localizedDescription)")
            return false
        }
    }
    
    func updateJournalPage(entries: [JournalEntry], journalID: UUID, pageNumber: Int) async {
        var previousEntryIds: [String] = []
        do {
            let document = try await db.collection("JOURNALS").document(journalID.uuidString).getDocument()
            if let data = document.data(),
               let pages = data["pages"] as? [String: [String]] {  // First get the pages dictionary
                previousEntryIds = pages["\(pageNumber + 1)"] as? [String] ?? []
            } else {
                print("Couldn't get page entries")
            }
            try await db.collection("JOURNALS").document(journalID.uuidString).updateData([
                "pages.\(pageNumber + 1)": []
            ])
        } catch {
            print("error reseting page entries")
            return
        }
        for entry in entries {
            if (entry.isFake == true) {
                continue
            }
            let entry_ref = db.collection("JOURNAL_ENTRIES").document(entry.id.uuidString)
            do {
                let journalEntryData = entry.toDictionary(journalID: journalID)
                try await entry_ref.updateData(journalEntryData)
                
                try await db.collection("JOURNALS").document(journalID.uuidString).updateData([
                    "pages.\(pageNumber + 1)": FieldValue.arrayUnion([entry.id.uuidString])
                ])
                if let removalIndex = previousEntryIds.firstIndex(of: entry.id.uuidString) {
                    previousEntryIds.remove(at: removalIndex)
                }
            } catch {
                await addJournalEntry(journalEntry: entry, journalID: journalID, pageNumber: pageNumber)
            }
        }
        for entry in previousEntryIds {
            if let uuid = UUID(uuidString: entry) {
                await removeJournalEntry(entryID: uuid)
            } else {
                print("Invalid UUID string: \(entry)")
            }
        }
    }
    
    func removeJournalEntry(entryID: UUID) async {
        do {
            try await db.collection("JOURNAL_ENTRIES").document(entryID.uuidString).delete()
        } catch {
            print("Error removing document: \(error)")
        }
    }
         
    
    func getJournalEntryFromID(id: String) async -> JournalEntry? {
        let journalEntryReference = db.collection("JOURNAL_ENTRIES").document(id)
        print(id)
        do {
            let document = try await journalEntryReference.getDocument()
            if let dict = document.data() {
                var x = JournalEntry.fromDictionary(dict)
                print(x)
                return JournalEntry.fromDictionary(dict)
            } else {
                return JournalEntry()
                //return nil
                print("fake entry improperly returned")
            }
        } catch {
            print("Error fetching Journal Shelf: \(error.localizedDescription)")
            return nil
        }
    }
    
    //#########################################################################################
    
    /****######################################################################################
    Images
     #########################################################################################**/
    
    func storeImage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            //completion(nil)
            print("image with url")
            return
        }
            // create random image path
        let imagePath = "images/\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference()
        // create reference to file you want to upload
        let imageRef = storageRef.child(imagePath)
        var urlString: String = ""
        //upload image
        
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
            } else {
                // Image successfully uploaded
                imageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        urlString = downloadURL.absoluteString
                        completion(urlString)
                    } else {
                        print("Error getting download URL: (String(describing: error?.localizedDescription))")
                    }
                }
            }
        }
    }
    
    func getImageFromURL(urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error loading image from URL: \(error.localizedDescription)")
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
            print("vector search error: \(error.localizedDescription)")
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
    
    func createConversationEntry(entry: JournalEntry, journalID: String) async -> Bool {
            let journalEntry = db.collection("JOURNAL_ENTRIES")
            var conversationEntryData: [String: Any]  = [
                "date": "",
                "entryContents": "",
                "conversationLog": [],
                "id": "\(entry.id)",
                "journal_id": journalID,
                "summary": "",
                "title": ""
            ]
            do {
                try await journalEntry.document("\(entry.id.uuidString)").setData(conversationEntryData)
                return true
                
            } catch {
                print("Error making document: \(error.localizedDescription)")
                return false
            }
        }
    func updateEntryWithConversationLog(id: UUID) async {
        let journalDoc = db.collection("JOURNAL_ENTRIES").document(id.uuidString)
        
        do {
            try await journalDoc.updateData([
                "conversationLog": []
            ])
        } catch {
            print("Error making document: \(error.localizedDescription)")
        }
        
        
    }
        
        func addConversationLog(text: [String], journalEntry: UUID) async -> Bool {
            let conversationEntry = db.collection("JOURNAL_ENTRIES").document("\(journalEntry.uuidString)")
            
            do {
                try await conversationEntry.updateData([
                    "conversationLog": text
                ])
                return true
                
            } catch {
                print("Error making document: \(error.localizedDescription)")
                return false
            }
        }
    
    func conversationEntryCheck(journalEntryID: UUID) async -> Bool {
        let entryDoc = db.collection("JOURNAL_ENTRIES").document("\(journalEntryID.uuidString)")
        do {
            let doc = try await entryDoc.getDocument()
            if doc.exists {
                return true
            } else {
                return false
            }
        } catch {
            print("Error making document: \(error.localizedDescription)")
            return false
        }
    }
    
    func loadConversationLog(for journalEntryID: String, viewModel: AIViewModel) async {
            let docRef = db.collection("JOURNAL_ENTRIES").document(journalEntryID)

            do {
                let document = try await docRef.getDocument()
                if let data = document.data(),
                   let conversationLog = data["conversationLog"] as? [String], !conversationLog.isEmpty {

                    await MainActor.run {
                        if viewModel.conversationHistory.isEmpty {
                            viewModel.conversationHistory = conversationLog
                        }
                    }
                }
            } catch {
                print("Error loading conversationLog: \(error.localizedDescription)")
            }
    }
    
    // SCRAPBOOKS
    func saveScrapbook(scrapbook: Scrapbook) async -> Bool {
        // Reference to the scrapbook document in Firestore.
        let scrapbookRef = db.collection("SCRAPBOOKS").document(scrapbook.id.uuidString)
        
        // Prepare the pages dictionary.
        var pagesDict: [String: [String]] = [:]
        
        // Iterate over each page.
        for page in scrapbook.pages {
            pagesDict[String(page.number)] = []
            // For each entry in the page, save it in the SCRAPBOOK_ENTRIES collection.
            for entry in page.entries {
                let entryRef = db.collection("SCRAPBOOK_ENTRIES").document(entry.id.uuidString)
                let entryData = entry.toDictionary(scrapbookID: scrapbook.id)
                do {
                    try await entryRef.setData(entryData)
                    // Add this entry's id to the page dictionary.
                    pagesDict[String(page.number)]?.append(entry.id.uuidString)
                } catch {
                    print("Error saving scrapbook entry \(entry.id): \(error.localizedDescription)")
                }
            }
        }
        
        // Create the scrapbook data using its toDictionary method and update the pages field.
        var scrapbookData = scrapbook.toDictionary()
        scrapbookData["pages"] = pagesDict
        
        // Save the scrapbook document.
        do {
            try await scrapbookRef.setData(scrapbookData)
            return true
        } catch {
            print("Error saving scrapbook: \(error.localizedDescription)")
            return false
        }
    }
    
    func loadScrapbook(scrapbookID: UUID) async -> Scrapbook? {
        let scrapbookRef = db.collection("SCRAPBOOKS").document(scrapbookID.uuidString)
        
        do {
            let document = try await scrapbookRef.getDocument()
            guard var data = document.data() else {
                print("No data found for scrapbook")
                return nil
            }
            
            // Extract the pages dictionary: keys are page numbers (as strings) and values are arrays of entry IDs.
            guard let pagesDict = data["pages"] as? [String: [String]] else {
                print("Pages field missing in scrapbook document")
                return nil
            }
            
            var pages: [ScrapbookPage] = []
            
            // For each page, fetch its entries.
            for (pageStr, entryIDs) in pagesDict {
                if let pageNum = Int(pageStr) {
                    var entries: [ScrapbookEntry] = []
                    for entryID in entryIDs {
                        let entryDoc = try await db.collection("SCRAPBOOK_ENTRIES").document(entryID).getDocument()
                        if let entryData = entryDoc.data(),
                           let entry = ScrapbookEntry.fromDictionary(entryData) {
                            entries.append(entry)
                        }
                    }
                    // Use the count of entries as the entryCount.
                    let page = ScrapbookPage(number: pageNum, entries: entries, entryCount: entries.count)
                    pages.append(page)
                }
            }
            
            // Sort pages by their number.
            pages.sort { $0.number < $1.number }
            
            // Convert pages to an array of dictionaries so that Scrapbook.fromDictionary can parse it.
            var pagesArray: [[String: Any]] = []
            for page in pages {
                pagesArray.append(page.toDictionary())
            }
            data["pages"] = pagesArray
            
            // Create and return the Scrapbook object.
            let scrapbook = Scrapbook.fromDictionary(data)
            return scrapbook
        } catch {
            print("Error loading scrapbook: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Add a single ScrapbookEntry to a specified page in a Scrapbook.
    func addScrapbookEntry(scrapbookEntry: ScrapbookEntry, scrapbookID: UUID, pageNumber: Int) async -> Bool {
        let entryRef = db.collection("SCRAPBOOK_ENTRIES").document(scrapbookEntry.id.uuidString)
        do {
            let entryData = scrapbookEntry.toDictionary(scrapbookID: scrapbookID)
            try await entryRef.setData(entryData)
            
            // Update the SCRAPBOOKS document to add the entry's ID to the corresponding page array.
            try await db.collection("SCRAPBOOKS").document(scrapbookID.uuidString).updateData([
                "pages.\(pageNumber)": FieldValue.arrayUnion([scrapbookEntry.id.uuidString])
            ])
            return true
        } catch {
            print("Error adding scrapbook entry \(scrapbookEntry.id): \(error.localizedDescription)")
            return false
        }
    }

    // Update all ScrapbookEntries on a specific page of a Scrapbook.
    // This function resets the page and then adds or updates entries. Any previous entries not in the new list are removed.
    func updateScrapbookPage(entries: [ScrapbookEntry], scrapbookID: UUID, pageNumber: Int) async {
        var previousEntryIds: [String] = []
        do {
            let document = try await db.collection("SCRAPBOOKS").document(scrapbookID.uuidString).getDocument()
            if let data = document.data(),
               let pages = data["pages"] as? [String: [String]] {
                previousEntryIds = pages["\(pageNumber)"] ?? []
            } else {
                print("Couldn't get page entries for Scrapbook page \(pageNumber)")
            }
            // Reset the page entries.
            try await db.collection("SCRAPBOOKS").document(scrapbookID.uuidString).updateData([
                "pages.\(pageNumber)": []
            ])
        } catch {
            print("Error resetting page entries for Scrapbook: \(error.localizedDescription)")
            return
        }
        
        for entry in entries {
            let entryRef = db.collection("SCRAPBOOK_ENTRIES").document(entry.id.uuidString)
            do {
                let entryData = entry.toDictionary(scrapbookID: scrapbookID)
                try await entryRef.setData(entryData)
                try await db.collection("SCRAPBOOKS").document(scrapbookID.uuidString).updateData([
                    "pages.\(pageNumber)": FieldValue.arrayUnion([entry.id.uuidString])
                ])
                if let removalIndex = previousEntryIds.firstIndex(of: entry.id.uuidString) {
                    previousEntryIds.remove(at: removalIndex)
                }
            } catch {
                // If updating fails, attempt to add the entry.
                await addScrapbookEntry(scrapbookEntry: entry, scrapbookID: scrapbookID, pageNumber: pageNumber)
            }
        }
        
        // Remove any previous entries that were not updated.
        for entryId in previousEntryIds {
            if let uuid = UUID(uuidString: entryId) {
                await removeScrapbookEntry(entryID: uuid)
            } else {
                print("Invalid UUID string for scrapbook entry: \(entryId)")
            }
        }
    }

    // Remove a ScrapbookEntry from Firestore.
    func removeScrapbookEntry(entryID: UUID) async {
        do {
            try await db.collection("SCRAPBOOK_ENTRIES").document(entryID.uuidString).delete()
        } catch {
            print("Error removing scrapbook entry \(entryID): \(error.localizedDescription)")
        }
    }

    // Fetch a ScrapbookEntry from Firestore using its document ID.
    func getScrapbookEntryFromID(id: String) async -> ScrapbookEntry? {
        let entryRef = db.collection("SCRAPBOOK_ENTRIES").document(id)
        do {
            let document = try await entryRef.getDocument()
            if let data = document.data(),
               let entry = ScrapbookEntry.fromDictionary(data) {
                return entry
            } else {
                print("No data found for scrapbook entry \(id)")
                return nil
            }
        } catch {
            print("Error fetching scrapbook entry \(id): \(error.localizedDescription)")
            return nil
        }
    }
    
}
