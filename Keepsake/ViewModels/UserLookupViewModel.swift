import Foundation
import FirebaseFirestore

class UserLookupViewModel: ObservableObject {
    @Published var users: [User] = []

    func searchUsers(searchText: String) {
        guard !searchText.isEmpty else {
            self.users = []
            return
        }
        
        let db = Firestore.firestore()
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
                

                if name.lowercased().hasPrefix(searchTextLowercased) || username.lowercased().hasPrefix(searchTextLowercased) {
                    return User(id: doc.documentID, name: name, username: username, journalShelves: [], scrapbookShelves: [], friends: friends, lastUsedShelfID: UUID(), isJournalLastUsed: true)
                }
                return nil
            }
            
            DispatchQueue.main.async {
                self.users = filteredUsers
            }
        }
    }
}


