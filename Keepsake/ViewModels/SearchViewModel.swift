////
////  SearchViewModel.swift
////  Keepsake
////
////  Created by Ishita on 3/23/25.
////
//
//import SwiftUI
//import FirebaseFirestore
//
//class SearchViewModel: ObservableObject {
//    private var db = Firestore.firestore()
//    
//    @Published var users: [User] = []
//    @Published var searchText: String = "" {
//        didSet {
//            searchUsers() // Run Firestore query on every change
//        }
//    }
//    
//    init() {
//        searchUsers() // Initial fetch
//    }
//    
//    /// 🔍 **Live Firestore Query for Users Matching `searchText`**
//    func searchUsers() {
//        guard !searchText.isEmpty else {
//            users = [] // Clear list if search is empty
//            return
//        }
//        
//        db.collection("users")
//            .whereField("name", isGreaterThanOrEqualTo: searchText) // Firestore search optimization
//            .whereField("name", isLessThanOrEqualTo: searchText + "\u{f8ff}") // Ensures results stay within the query range
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching users: \(error.localizedDescription)")
//                    return
//                }
//                
//                self.users = snapshot?.documents.compactMap { document in
//                    let data = document.data()
//                    if let name = data["name"] as? String {
//                        return User(id: document.documentID, name: name, journalShelves: [], scrapbookShelves: [], savedTemplates: [])
//                    } else {
//                        return nil
//                    }
//                } ?? []
//            }
//    }
//}
//
//

import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var users: [User] = [
        User(id: "1", name: "Alice", journalShelves: [], scrapbookShelves: []),
        User(id: "2", name: "Bob", journalShelves: [], scrapbookShelves: []),
        User(id: "3", name: "Charlie", journalShelves: [], scrapbookShelves: []),
        User(id: "4", name: "David", journalShelves: [], scrapbookShelves: []),
        User(id: "5", name: "Eve", journalShelves: [], scrapbookShelves: []),
        User(id: "6", name: "Frank", journalShelves: [], scrapbookShelves: []),
    ]
    
    @Published var searchText: String = "" {
        didSet {
            filterUsers()
        }
    }
    
    @Published var filteredUsers: [User] = []
    
    init() {
        filterUsers()
    }
    
    func filterUsers() {
        if searchText.isEmpty {
            filteredUsers = []
        } else {
            filteredUsers = users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}
