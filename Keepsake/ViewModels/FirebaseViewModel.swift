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
    @Published var retrievedImage: UIImage?
    let auth = Auth.auth()
    static let vm = FirebaseViewModel()
    func configure() {
        self.onSetupCompleted?(self)
    }
    
    @Published var initializedUser: Bool = false
        
    @Published var users: [User] = []
    
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
        self.userSession = auth.currentUser
        
        Task {
            await fetchUser()
            await MainActor.run {
                self.initializedUser = true
                self.objectWillChange.send()
            }
            
        }
    }
    

    /****######################################################################################
    USER
     #########################################################################################**/

    
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
            let initialScrapbookShelf = ScrapbookShelf(name: "Initial Shelf", id: UUID(), scrapbooks: [])
            self.userSession = result.user
            let user = User(id: result.user.uid, name: fullname, username: email, journalShelves: [], scrapbookShelves: [], savedTemplates: [], friends: [], lastUsedJShelfID: initialShelf.id, lastUsedSShelfID: initialScrapbookShelf.id, isJournalLastUsed: true)
            let userData: [String: Any] = [
                "uid": user.id,
                "name": user.name,
                "username": user.username,
                "journalShelves": ["\(initialShelf.id)"],
                "scrapbookShelves": ["\(initialScrapbookShelf.id)"],
                "templates": [],
                "friends": [],

                "streaks": 0,
                "lastJournaled": Date().timeIntervalSince1970,

                "lastUsedJShelfID": "\(initialShelf.id)",
                "lastUsedSShelfID": "\(initialScrapbookShelf.id)",
                "isJournalLastUsed": true,
                "savedScrapbookIDs": []

            ]
            try await Firestore.firestore().collection("USERS").document(user.id).setData(userData)
            await self.addJournalShelf(journalShelf: initialShelf, userID: user.id)
            await self.addScrapbookShelf(scrapbookShelf: initialScrapbookShelf, userID: user.id)
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
    func getFriends(for userID: String) async -> [String] {
        let db = Firestore.firestore()
        let userRef = db.collection("USERS").document(userID)
        
        do {
            let snapshot = try await userRef.getDocument()
            if let data = snapshot.data(), let friends = data["friends"] as? [String] {
                return friends
            }
        } catch {
            print("Error fetching friends: \(error)")
        }
        
        return []
    }

    func scheduleReminderNotifications(for uid: String) {
            let db = Firestore.firestore()
            let remindersRef = db.collection("reminders")
            
            remindersRef.getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching reminders: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found.")
                    return
                }
                for document in documents {
                    let data = document.data()
                    
                    if let userId = data["uid"] as? String, userId == uid {
                        if let dateTimestamp = data["date"] as? Timestamp {
                            let date = dateTimestamp.dateValue()
                            self.scheduleNotification(at: date, identifier: document.documentID)
                        }
                    }
                }
            }
        }

        private func scheduleNotification(at date: Date, identifier: String) {
            let content = UNMutableNotificationContent()
            content.title = "Journal Reminder"
            content.body = "Listen to your recording to recollect your thoughts"
            content.sound = .default
            content.categoryIdentifier = "PROFILE_REMINDER_CATEGORY"
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("didn't work")
                } else {
                    print("scheduled reminder yay")
                }
            }
        }
    func deleteAccount() {
        
    }
    
//    func fetchOtherUser(newUserID: String) async -> UserInfo {
//        
//        do {
//            guard let snapshot = try? await Firestore.firestore().collection("USERS").document(newUserID).getDocument() else { return nil}
//            if snapshot.exists {
//                // Manually extract data from the snapshot
//                if let uid = snapshot.get("uid") as? String,
//                   let name = snapshot.get("name") as? String,
//                   let username = snapshot.get("username") as? String,
//                   let journalShelfIds = snapshot.get("journalShelves") as? [String],
//                   let scrapbookShelfIds = snapshot.get("scrapbookShelves") as? [String],
//                   let templates = snapshot.get("templates") as? [String],
//                   let friends = snapshot.get("friends") as? [String],
//                   let lastUsedJ = snapshot.get("lastUsedJShelfID") as? String,
//                   let lastUsedS = snapshot.get("lastUsedSShelfID") as? String,
//                   let isJournalLastUsed = snapshot.get("isJournalLastUsed") as? Bool
//                {
//                    var journalShelves: [JournalShelf] = []
//                    for astr in journalShelfIds {
//                        let shelf = await getJournalShelfFromID(id: astr)!
//                        journalShelves.append(shelf)
//                    }
//                    let lastUsedJID: UUID
//                    if let temp = UUID(uuidString: lastUsedJ) {
//                        lastUsedJID = temp
//                    } else {
//                        print("Error getting last used journal ID")
//                        lastUsedJID = UUID()
//                    }
//                    
//                    let lastUsedSID: UUID
//                    if let temp = UUID(uuidString: lastUsedS) {
//                        lastUsedSID = temp
//                    } else {
//                        print("Error getting last used scrapbook shelf ID")
//                        lastUsedSID = UUID()
//                    }
//                    let user = User(id: uid, name: name, username: username, journalShelves: journalShelves, scrapbookShelves: [], savedTemplates: [], friends: friends, lastUsedJShelfID: lastUsedJID, lastUsedSShelfID: lastUsedSID, isJournalLastUsed: isJournalLastUsed)
//                    
//                    return user
//                    
//                }
//            }
//        }
//        
//        return nil
//        
//    }
    
    func getUserInfo(userID: String) async -> UserInfo? {
        let docRef = db.collection("USERS").document(userID)
        do {
            let userDoc = try await docRef.getDocument()
            guard userDoc.exists, let data = userDoc.data() else { return nil }
            
            let name = (data["name"] as? String) ?? "Unknown"
            let username = (data["username"] as? String) ?? "unknown"
            let friends = (data["friends"] as? [String]) ?? []
            let profilePic = await getProfilePic(uid: userID)
            let streakCount = data["streakCount"] as? Int ?? 0
            return (userID: userID, name: name, username: username, profilePic: profilePic, friends: friends)
        } catch {
            print("Error getting user info: \(error)")
            return nil
        }
    }
    func getUserInfoWithStreaks(userID: String) async -> UserInfoWithStreaks? {
        let docRef = db.collection("USERS").document(userID)
        do {
            let userDoc = try await docRef.getDocument()
            guard userDoc.exists, let data = userDoc.data() else { return nil }
            
            let name = (data["name"] as? String) ?? "Unknown"
            let username = (data["username"] as? String) ?? "unknown"
            let friends = (data["friends"] as? [String]) ?? []
            let profilePic = await getProfilePic(uid: userID)
            let streakCount = data["streakCount"] as? Int ?? 0
            return (userID: userID, name: name, username: username, profilePic: profilePic, friends: friends, streakCount: streakCount)
        } catch {
            print("Error getting user info: \(error)")
            return nil
        }
    }
    
    func fetchUser() async {
        guard let uid = auth.currentUser?.uid else {return}
        print("Fetch User Started")
        guard let snapshot = try? await Firestore.firestore().collection("USERS").document(uid).getDocument() else { return }
        print("Hello darkness")
        if snapshot.exists {
            print("It exits")
            // Manually extract data from the snapshot
            if let uid = snapshot.get("uid") as? String,
               let name = snapshot.get("name") as? String,
               let username = snapshot.get("username") as? String,
               let journalShelfIds = snapshot.get("journalShelves") as? [String],
               let scrapbookShelfIds = snapshot.get("scrapbookShelves") as? [String],
               let templates = snapshot.get("templates") as? [String],
               let friends = snapshot.get("friends") as? [String],
               let lastUsedJ = snapshot.get("lastUsedJShelfID") as? String,
               let lastUsedS = snapshot.get("lastUsedSShelfID") as? String,
               let isJournalLastUsed = snapshot.get("isJournalLastUsed") as? Bool,
               let savedScrapbookIDs = snapshot.get("savedScrapbookIDs") as? [String]
            {
                var scrapbookShelves: [ScrapbookShelf] = []
                for scrapbookShelfId in scrapbookShelfIds {

                    //let shelf = await getScrapbookShelfFromID(id: scrapbookShelfId) ?? ScrapbookShelf(name: "New Shelf", id: UUID(), scrapbooks: [])

                    print(scrapbookShelfId)
                    let shelf = await getScrapbookShelfFromID(id: scrapbookShelfId) ?? ScrapbookShelf(name: "New Shelf", id: UUID(), scrapbooks: [])

                    scrapbookShelves.append(shelf)

                }
                var journalShelves: [JournalShelf] = []
                for journalShelfID in journalShelfIds {
                    let shelf = await getJournalShelfFromID(id: journalShelfID)!
                    journalShelves.append(shelf)
                }
                let lastUsedJID: UUID
                if let temp = UUID(uuidString: lastUsedJ) {
                    lastUsedJID = temp
                } else {
                    print("Error getting last used journal ID")
                    lastUsedJID = UUID()
                }
                print("Halloween")
                let lastUsedSID: UUID
                if let temp = UUID(uuidString: lastUsedS) {
                    lastUsedSID = temp
                } else {
                    print("Error getting last used scrapbook shelf ID")
                    lastUsedSID = UUID()
                }
                var imageDict: [String: UIImage] = [:]
                for shelf in journalShelves {
                    for journal in shelf.journals {
                        for page in journal.pages {
                            for entry in page.entries {
                                if let entry = entry as? PictureEntry {
                                    for url in entry.images {
                                        if let image = await getImageFromURL(urlString: url) {
                                            imageDict[url] = image
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                print("is journal: \(isJournalLastUsed)")
                var savedScrapbooks: [Scrapbook] = []
                for scrapbookID in savedScrapbookIDs {
                    if scrapbookID.isEmpty { continue }
                    let scrapbook = await loadScrapbook(scrapbookID: scrapbookID)
                    if let unwrapped = scrapbook {
                        savedScrapbooks.append(unwrapped)
                    }
                }
                let communityScrapbooks = await getAllSharedScrapbooks(userID: uid)
                print("communityScrapbooks: \(communityScrapbooks)")
                let user = User(id: uid, name: name, username: username, journalShelves: journalShelves, scrapbookShelves: scrapbookShelves, savedTemplates: [], friends: friends, lastUsedJShelfID: lastUsedJID, lastUsedSShelfID: lastUsedSID, isJournalLastUsed: isJournalLastUsed, images: imageDict, communityScrapbooks: communityScrapbooks, savedScrapbooks: savedScrapbooks)
                
                // Assign the user object to currentUser
                await MainActor.run {
                    self.currentUser = user
                }
                
            }
        }
    }
    
    
    func storeProfilePic(image: UIImage) {
            guard let uid = currentUser?.id else { return }
            let file = "\(uid).jpg"
            let storageRef = Storage.storage().reference(withPath: "profile pic/\(file)")
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                storageRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
                    if let error = error {
                        print("Error uploading the image: \(error.localizedDescription)")
                        return
                    }
                    print("Image uploaded successfully!")
                    
                }
            }
        }
    
    func getProfilePic(uid: String) async -> UIImage? {
        guard !uid.isEmpty else { return nil }
        
        let storageRef = Storage.storage().reference().child("profile pic").child("\(uid).jpg")
        
        do {
            let data = try await storageRef.data(maxSize: 3 * 2048 * 2048)
            return UIImage(data: data)
        } catch {
            print("Error fetching profile picture: \(error.localizedDescription)")
            return nil
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
    
    //#########################################################################################
    

    
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
                let favoritePages = dict["favoritePages"] as? [Int] ?? []
                
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
                let sortedPages = journalPages.sorted { $0.number < $1.number }
                return Journal(name: name, id: id, createdDate: createdDate, category: category, isSaved: isSaved, isShared: isShared, template: template, pages: sortedPages, currentPage: currentPage, favoritePages: favoritePages)
                
            } else {
                print("No document found")
                return nil
            }
        } catch {
            print("Error fetching Journal Shelf: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateFavoritePages(journalID: UUID, newPages: [Int]) async {
        let journal_reference = db.collection("JOURNALS").document(journalID.uuidString)
        do {
            try await journal_reference.updateData([
                "favoritePages": newPages
            ])
        } catch {
            print("Error updating pages: \(error.localizedDescription)")
        }
    }
    
    func updateCurrentPage(journalID: UUID, currentPage: Int) async {
        let journal_reference = db.collection("JOURNALS").document(journalID.uuidString)
        do {
            try await journal_reference.updateData([
                "currentPage": currentPage
            ])
        } catch {
            print("Error updating currentPage: \(error.localizedDescription)")
        }
    }
    
    //#########################################################################################
    
    /****######################################################################################
    STICKERS
     #########################################################################################**/
    
    func clearStickers(journalID: UUID) async {
        let stickersRef = db.collection("JOURNALS")
            .document(journalID.uuidString)
            .collection("STICKERS")

        do {
            let snapshot = try await stickersRef.getDocuments()
            
            // If the collection doesn't exist or is empty
            guard !snapshot.isEmpty else {
                print("Collection is empty or does not exist.")
                return
            }
            
            let batch = db.batch()
            
            for doc in snapshot.documents {
                batch.deleteDocument(doc.reference)
            }
            
            try await batch.commit()
            print("Collection cleared successfully.")
            
        } catch {
            print("Failed to clear stickers: \(error)")
        }
    }
    
    func saveStickers(journal: Journal) async {
        let stickers_reference = db.collection("JOURNALS").document(journal.id.uuidString).collection("STICKERS")
        
        for page in journal.pages {
            for sticker in page.placedStickers {
                do {
                    let stickerRef = stickers_reference.document(sticker.id.uuidString)
                    var stickerData = sticker.toDictionary()
                    stickerData["pageNum"] = page.number
                    try await stickerRef.setData(stickerData)
                } catch {
                    print("Error adding sticker: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func retrieveStickers(journal: Journal) async {
        let stickersRef = db.collection("JOURNALS")
            .document(journal.id.uuidString)
            .collection("STICKERS")

        do {
            let snapshot = try await stickersRef.getDocuments()
            
            // If the collection doesn't exist or is empty
            guard !snapshot.isEmpty else {
                print("Collection is empty or does not exist.")
                return
            }
            
            
            for doc in snapshot.documents {
                let data = doc.data()
                if let sticker = Sticker.fromDictionary(data) {
                    let pageNum = data["pageNum"] as? Int ?? 1
                    journal.pages[pageNum - 1].placedStickers.append(sticker)
                }
            }
            
        } catch {
            print("Failed to clear stickers: \(error)")
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
                        await retrieveStickers(journal: journal)
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
    
    func updateUserLastUsedJShelf(user: User) async {
        let userRef = db.collection("USERS").document(user.id)
        do {
            try await userRef.updateData([
                "lastUsedJShelfID": user.lastUsedJShelfID.uuidString,
                "isJournalLastUsed": user.isJournalLastUsed
            ])
        } catch {
            print("error setting last used shelf")
        }
    }
    
    func updateUserLastUsedSShelf(user: User) async {
        let userRef = db.collection("USERS").document(user.id)
        do {
            try await userRef.updateData([
                "lastUsedSShelfID": user.lastUsedSShelfID.uuidString,
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
            var journalEntryData = journalEntry.toDictionary(journalID: journalID)
            
            print(journalEntryData["audioURL"])
            
            try await journal_entry_reference.setData(journalEntryData)
            
            try await db.collection("JOURNALS").document(journalID.uuidString).updateData([
                "pages.\(pageNumber + 1)": FieldValue.arrayUnion([journalEntry.id.uuidString])
            ])
            
            //after the user adds an entry, this code checks streak stuff
            let firestoreTimestamp = Timestamp(date: Date())
            
            let userRef = db.collection("USERS").document((currentUser?.id)!)
            do {
                
                let document = try await userRef.getDocument()
                    let data = document.data()
                    let streaks = data?["streaks"] as? Int ?? 0
                    let lastJournaledTimestamp = data?["lastJournaled"] as? Timestamp
                    let lastJournaledDate = lastJournaledTimestamp?.dateValue() ?? Date.distantPast
                    if streaks == 0 || Date().timeIntervalSince(lastJournaledDate) >= 24 * 60 * 60 {
                        currentUser?.lastJournaled = Date().timeIntervalSince1970
                        currentUser?.streaks = streaks + 1

                        try await userRef.updateData([
                            "streaks": currentUser?.streaks ?? 1,
                            "lastJournaled": firestoreTimestamp
                        ])
                    }
            }
            return true
        } catch {
            print("Error adding journal: \(error.localizedDescription)")
            return false
        }
        
    }
    
    func checkIfStreaksRestarted() async {
        let userRef = db.collection("USERS").document((currentUser?.id)!)
        do {
            
            let document = try await userRef.getDocument()
                let data = document.data()
                let streaks = data?["streaks"] as? Int ?? 0
                let lastJournaledTimestamp = data?["lastJournaled"] as? Timestamp
                let lastJournaledDate = lastJournaledTimestamp?.dateValue() ?? Date.distantPast
                if streaks != 0 && Date().timeIntervalSince(lastJournaledDate) > 24 * 60 * 60 {
                    currentUser?.lastJournaled = Date().timeIntervalSince1970
                    try await userRef.updateData([
                        "streaks": 0
                    ])
                }
        } catch {
            
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
            try await db.collection("JOURNALS").document(journalID.uuidString).updateData([
                "currentPage": pageNumber
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
            var journalEntryData = entry.toDictionary(journalID: journalID)
            
            do {
                if let voiceEntry = entry as? VoiceEntry, let audioData = voiceEntry.audio {
                    var result = await uploadAudio(audioData, fileName: UUID().uuidString)
                    
                    switch result {
                    case .success(let url):
                        voiceEntry.audioURL = url.absoluteString
                        journalEntryData["audioURL"] = url.absoluteString
                    case .failure(let error):
                        print("Failed to upload audio:", error.localizedDescription)
                    }
                }
                
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
        for oldEntryID in previousEntryIds {
            for entry in entries {
                if entry.id.uuidString == oldEntryID {
                    continue
                }
            }
            if let uuid = UUID(uuidString: oldEntryID) {
                await removeJournalEntry(entryID: uuid)
            } else {
                print("Invalid UUID string: \(oldEntryID)")
            }
        }
    }
    
    func deletePage(journalID: UUID, pageNumber: Int) async {
        do {
            let docRef = db.collection("JOURNALS").document(journalID.uuidString)
            let document = try await docRef.getDocument()
            
            guard var data = document.data(),
                  var pages = data["pages"] as? [String: [String]] else {
                print("Couldn't get page entries")
                return
            }
            
            // 1. Delete entries for this page
            let entryIDs = pages["\(pageNumber)"] ?? []
            for entry in entryIDs {
                if let entryID = UUID(uuidString: entry) {
                    await removeJournalEntry(entryID: entryID)
                }
            }
            
            // 2. Remove the page
            pages.removeValue(forKey: "\(pageNumber)")
            
            // 3. Decrement higher-numbered pages
            var updatedPages = [String: [String]]()
            
            // Sort the remaining pages by their number
            let sortedKeys = pages.keys.compactMap { Int($0) }.sorted()
            
            for oldPageNum in sortedKeys {
                if oldPageNum < pageNumber {
                    // Keep pages before the deleted one as-is
                    updatedPages["\(oldPageNum)"] = pages["\(oldPageNum)"]
                } else if oldPageNum > pageNumber {
                    // Decrement pages after the deleted one
                    updatedPages["\(oldPageNum - 1)"] = pages["\(oldPageNum)"]
                }
                // Skip the deleted page (oldPageNum == pageNumber)
            }
            
            // 4. Update Firestore
            try await docRef.updateData(["pages": updatedPages])
            
            print("Successfully deleted page \(pageNumber) and updated subsequent pages")
            
        } catch {
            print("Error deleting page: \(error)")
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
//                let je: JournalEntry = (JournalEntry.fromDictionary(dict) as JournalEntry?)!
//                print(je.id)
                return JournalEntry.fromDictionary(dict)
            } else {
                print("fake entry improperly returned")
                return JournalEntry()
                //return nil
            }
        } catch {
            print("Error fetching Journal Shelf: \(error.localizedDescription)")
            return nil
        }
    }
    
    //#########################################################################################
    
    /****######################################################################################
    IMAGES
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
    
    func convertImageToURL(image: UIImage) async -> String {
        await withCheckedContinuation { continuation in
            storeImage(image: image) { urlString in
                continuation.resume(returning: urlString ?? "")
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
    
    /****######################################################################################
    VECTOR SEARCH
     #########################################################################################**/
    
    
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
    
    //#########################################################################################
    
    /****######################################################################################
    CONVERSATION ENTRY
     #########################################################################################**/
    
    func createConversationEntry(entry: JournalEntry, journalID: String) async -> Bool {
        let journalEntry = db.collection("JOURNAL_ENTRIES")
        var conversationEntryData: [String: Any]  = [
            "date": "",
            "entryContents": "",
            "conversationLog": [],
            "id": entry.id.uuidString,
            "journal_id": journalID,
            "summary": "",
            "title": ""
        ]
        do {
            try await journalEntry.document(entry.id.uuidString).setData(conversationEntryData)
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
        let docRef = db.collection("JOURNAL_ENTRIES").document(journalEntry.uuidString)
        
        do {
            try await docRef.updateData([
                "conversationLog": text,
            ])
            return true
        } catch {
            print("Error updating document: \(error.localizedDescription)")
            return false
        }
    }
    
    func conversationEntryCheck(journalEntryID: UUID) async -> (exists: Bool, hasContent: Bool) {
        let entryDoc = db.collection("JOURNAL_ENTRIES").document(journalEntryID.uuidString)
        do {
            let doc = try await entryDoc.getDocument()
            guard doc.exists,
                  let data = doc.data(),
                  let logs = data["conversationLog"] as? [String] else {
                return (false, false)
            }
            return (true, !logs.isEmpty)
        } catch {
            print("Error checking document: \(error.localizedDescription)")
            return (false, false)
        }
    }
    
    func loadConversationLog(for journalEntryID: String, aiVM: AIViewModel) async -> Bool {
        let docRef = db.collection("JOURNAL_ENTRIES").document(journalEntryID)
        
        do {
            let document = try await docRef.getDocument()
            guard document.exists,
                  let data = document.data(),
                  let logs = data["conversationLog"] as? [String] else {
                return false
            }
            
            await MainActor.run {
                aiVM.conversationHistory = logs
            }
            return true
        } catch {
            print("Error loading conversationLog: \(error.localizedDescription)")
            return false
        }
    }
    
    //#########################################################################################
    
    /****######################################################################################
    SCRAPBOOK SHELF
     #########################################################################################**/
    
    func addScrapbookShelf(scrapbookShelf: ScrapbookShelf, userID: String) async -> Bool {
        let scrapbookShelfReference = db.collection("SCRAPBOOK_SHELVES").document(scrapbookShelf.id.uuidString)
        do {
            // Chains together each Model's "toDictionary()" method for simplicity in code and scalability in editing each Model
            let scrapbookShelfData = scrapbookShelf.toDictionary()
            try await scrapbookShelfReference.setData(scrapbookShelfData)
            
            try await db.collection("USERS").document(userID).updateData([
                "scrapbookShelves": FieldValue.arrayUnion([scrapbookShelf.id.uuidString])
            ])
            return true
        } catch {
            print("Error adding Journal Shelf: \(error.localizedDescription)")
            return false
        }
    }
    
    func getScrapbookShelfFromID(id: String) async -> ScrapbookShelf? {
        let journalShelfReference = db.collection("SCRAPBOOK_SHELVES").document(id)
        do {
            let document = try await journalShelfReference.getDocument()
            if let data = document.data() {
                let name = data["name"] as? String ?? ""
                let idString = data["id"] as? String ?? ""
                let id = UUID(uuidString: idString) ?? UUID()
                let scrapbookIDs = data["scrapbooks"] as? [String] ?? []
                
                var arrScrapbooks: [Scrapbook] = []
                
                for scrapbookID in scrapbookIDs {
                    if scrapbookID.isEmpty { continue }
                    let scrapbook = await loadScrapbook(scrapbookID: scrapbookID)
                    if let scrapbook = scrapbook {
                        arrScrapbooks.append(scrapbook)
                    }
                }
                return ScrapbookShelf(name: name, id: id, scrapbooks: arrScrapbooks)
                
            } else {
                print("No document found")
                return nil
            }
        } catch {
            print("Error fetching Journal Shelf: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteScrapbookShelf(shelfID: UUID, userID: String) async {
        // Delete all scrapbooks
        do {
            let document = try await db.collection("SCRAPBOOK_SHELVES").document(shelfID.uuidString).getDocument()
            if let data = document.data(),
               let scrapbooks = data["scrapbooks"] as? [String] {
                for scrapbook in scrapbooks {
                    await deleteScrapbook(scrapbookID: scrapbook, scrapbookShelfID: shelfID)
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
            try await documentRef.updateData(["scrapbookShelves": FieldValue.arrayRemove([shelfID.uuidString])])
        } catch {
            print("could not remove shelf from user")
            return
        }
        //Remove Journal
        do {
            try await db.collection("SCRAPBOOK_SHELVES").document(shelfID.uuidString).delete()
        } catch {
            print("Error removing shelf: \(error)")
        }
    }
    
    func updateScrapbookShelfName(shelfID: UUID, newName: String) async {
        let shelfRef = db.collection("SCRAPBOOK_SHELVES").document(shelfID.uuidString)
        do {
            try await shelfRef.updateData([
                "name": newName
            ])
        } catch {
            print("error renaming shelf")
        }
    }
    
    //#########################################################################################
    
    /****######################################################################################
    SCRAPBOOKS
     #########################################################################################**/
    
    
    func addScrapbook(scrapbook: Scrapbook, scrapbookShelfID: UUID) async {
        let scrapbook_reference = db.collection("SCRAPBOOKS").document(scrapbook.id.uuidString)
        do {
            let scrapbookData = scrapbook.toDictionary()
            try await scrapbook_reference.setData(scrapbookData)
            
            try await db.collection("SCRAPBOOK_SHELVES").document(scrapbookShelfID.uuidString).updateData([
                "scrapbooks": FieldValue.arrayUnion([scrapbook.id.uuidString])
            ])
            
        } catch {
            print("Error adding journal: \(error.localizedDescription)")

        }
    }
    
    func loadScrapbook(scrapbookID: String) async -> Scrapbook? {
        let scrapbookReference = db.collection("SCRAPBOOKS").document(scrapbookID)
        
        do {
            let document = try await scrapbookReference.getDocument()
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
                
                var scrapbookPages: [ScrapbookPage] = []
                
                for (page, entryIDs) in pagesArray {
                    print("scrapbook page; \(page)")
                    let num = page
                    let entryCount = entryIDs.count
                    print("scrapbook entries; \(entryIDs)")
                    var scrapbookEntries: [ScrapbookEntry] = []
                    
                    for entryID in entryIDs {
                        let entry = await getScrapbookEntryFromID(id: entryID)
                        if let entry = entry {
                            scrapbookEntries.append(entry)
                            
                        }
                        
                        
                    }
                    scrapbookPages.append(ScrapbookPage(number: Int(num) ?? 0, entries: scrapbookEntries, entryCount: entryCount))
                }
                let sortedPages = scrapbookPages.sorted { $0.number < $1.number }
                return Scrapbook(name: name, id: id, createdDate: createdDate, category: category, isSaved: isSaved, isShared: isShared, template: template, pages: sortedPages, currentPage: currentPage)
                
            } else {
                print("No document found")
                return nil
            }
        } catch {
            print("Error fetching Journal Shelf: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteScrapbook(scrapbookID: String, scrapbookShelfID: UUID) async {
        var allEntryIds: [String] = []
        // Delete all entries
        do {
            let document = try await db.collection("SCRAPBOOKS").document(scrapbookID).getDocument()
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
                    await removeScrapbookEntry(entryID: uuid)
                } else {
                    print("Invalid UUID string: \(entry)")
                }
            }
        } catch {
            print("error deleting entries")
            return
        }
        // Remove Journal Id from journal Shelf
        let documentRef = db.collection("SCRAPBOOK_SHELVES").document(scrapbookShelfID.uuidString)
        do {
            try await documentRef.updateData(["scrapbooks": FieldValue.arrayRemove([scrapbookID])])
        } catch {
            print("could not remove scrapbook ID from shelf")
            return
        }
        //Remove Journal
        do {
            try await db.collection("SCRAPBOOKS").document(scrapbookID).delete()
        } catch {
            print("Error removing document: \(error)")
        }
    }
    
    func getAllSharedScrapbooks(userID: String) async -> [Scrapbook: [UserInfo]] {
        var sharedScrapbooks: [Scrapbook : [UserInfo]] = [:]
        do {
            let snapshot = try await db.collection("USERS").getDocuments()
            for userDoc in snapshot.documents {
                let otherUserID = userDoc.documentID
                let name = (userDoc.data()["name"] as? String) ?? "Unknown"
                let profilePic = await getProfilePic(uid: otherUserID)
                let username = (userDoc.data()["username"] as? String) ?? "unknown"
                let friends = (userDoc.data()["friends"] as? [String]) ?? []
                if otherUserID == userID { continue }
                let userDoc = try await db.collection("USERS").document(otherUserID).getDocument()
                let shelfIDs = (userDoc.data()?["scrapbookShelves"] as? [String]) ?? []
                for shelfID in shelfIDs {
                    let shelfDoc = try await db.collection("SCRAPBOOK_SHELVES").document(shelfID).getDocument()
                    let scrapbookIDs = (shelfDoc.data()?["scrapbooks"] as? [String]) ?? []
                    for scrapbookID in scrapbookIDs {
                        let scrapbook = await loadScrapbook(scrapbookID: scrapbookID)
                        if let unwrapped = scrapbook {
                            if !unwrapped.isShared { continue }
                            let userInfo = (userID: otherUserID, name: name, username: username, profilePic: profilePic, friends: friends)
                            sharedScrapbooks[unwrapped, default: []].append(userInfo)
                            
                        }
                    }
                }
            }
        } catch {
            print("Error in get all shared scrap function")
        }
        
        return sharedScrapbooks
    }
    
    func updateSavedScrapbooks(userID: String, newScrapbooks: [Scrapbook]) async {
        var scrapbookIDs: [String] = []
        for scrapbook in newScrapbooks {
            scrapbookIDs.append(scrapbook.id.uuidString)
        }
        let journal_reference = db.collection("USERS").document(userID)
        do {
            try await journal_reference.updateData([
                "savedScrapbookIDs": scrapbookIDs
            ])
        } catch {
            print("Error updating pages: \(error.localizedDescription)")
        }
    }
    
    //#########################################################################################
    
    /****######################################################################################
    SCRAPBOOK ENTRY
     #########################################################################################**/
    
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
            if let data = document.data() {
                if let entry = ScrapbookEntry.fromDictionary(data) {
                    return entry
                } else {
                    print("From dictionary doesn't work \(id)")
                    return nil
                }
            } else {
                print("No data found for scrapbook entry \(id)")
                return nil
            }
        } catch {
            print("Error fetching scrapbook entry \(id): \(error.localizedDescription)")
            return nil
        }
    }
    
    //#########################################################################################
    
    /****######################################################################################
    FRIENDS
     #########################################################################################**/
    func addFriend(currentUserID: String, friendUserID: String) {
        let userRef = db.collection("USERS").document(currentUserID)
        
        userRef.updateData(["friends": FieldValue.arrayUnion([friendUserID])]) { error in
            if let error = error {
                print("Error adding friend: \(error)")
            } else {
                if let index = self.users.firstIndex(where: { $0.id == friendUserID }) {
                    self.users[index].friends.append(currentUserID)
                    self.objectWillChange.send()
                }
            }
        }
    }
    func removeFriend(currentUserID: String, friendUserID: String) {
        let userRef = db.collection("USERS").document(currentUserID)
        
        userRef.updateData(["friends": FieldValue.arrayRemove([friendUserID])]) { error in
            if let error = error {
                print("Error removing friend: \(error)")
            } else {
                if let index = self.users.firstIndex(where: { $0.id == friendUserID }) {
                    self.users[index].friends.removeAll { $0 == currentUserID }
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    func searchUsers(searchText: String, currentUserName: String) {
        guard !searchText.isEmpty else {
            self.users = []
            return
        }
        
        let searchTextLowercased = searchText.lowercased()

        db.collection("USERS").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                DispatchQueue.main.async {
                    self.users = []
                }
                return
            }

            let filteredUsers = documents.compactMap { doc -> User? in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let username = data["username"] as? String,
                      let friends = data["friends"] as? [String] else { return nil }
                

                if name.lowercased().hasPrefix(searchTextLowercased) && username != currentUserName {
                    return User(id: doc.documentID, name: name, username: username, journalShelves: [], scrapbookShelves: [], friends: friends, lastUsedJShelfID: UUID(), lastUsedSShelfID: UUID(), isJournalLastUsed: true)
                }
                return nil
            }
            
            DispatchQueue.main.async {
                self.users = filteredUsers
            }
        }
    }
    
    
    
    
    
    //#########################################################################################
    
    /****######################################################################################
    MISCELLANEOUS
     #########################################################################################**/
    
    
    func uploadAudio(_ audioData: Data, fileName: String) async -> Result<URL, Error> {
        let storageRef = Storage.storage().reference().child("audio/\(fileName).m4a")

        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"

        do {
            // Upload the audio data
            let _ = try await storageRef.putDataAsync(audioData, metadata: metadata)
            
            // Download the URL after upload
            let url = try await storageRef.downloadURL()
            return .success(url)
        } catch {
            return .failure(error)
        }
    }
    
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
