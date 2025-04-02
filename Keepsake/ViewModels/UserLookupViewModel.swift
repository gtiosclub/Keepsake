import Foundation
import FirebaseFirestore

class UserLookupViewModel: ObservableObject {
    @Published var users: [User] = []

    func addFriend(currentUserID: String, friendUserID: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("USERS").document(currentUserID)
        
        userRef.updateData(["friends": FieldValue.arrayUnion([friendUserID])]) { error in
            if let error = error {
                print("Error adding friend: \(error)")
            } else {
                // Update local users array after successful friend addition
                if let index = self.users.firstIndex(where: { $0.id == friendUserID }) {
                    self.users[index].friends.append(currentUserID)
                }
            }
        }
    }
    func removeFriend(currentUserID: String, friendUserID: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("USERS").document(currentUserID)
        
        userRef.updateData(["friends": FieldValue.arrayRemove([friendUserID])]) { error in
            if let error = error {
                print("Error removing friend: \(error)")
            } else {
                // Update local users array after successful friend removal
                if let index = self.users.firstIndex(where: { $0.id == friendUserID }) {
                    self.users[index].friends.removeAll { $0 == currentUserID }
                }
            }
        }
    }
    
    func searchUsers(searchText: String, currentUserName: String) {
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
                

                if name.lowercased().hasPrefix(searchTextLowercased) && username != currentUserName {
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


