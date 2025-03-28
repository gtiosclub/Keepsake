//
//  SearchViewModel.swift
//  Keepsake
//
//  Created by Ishita on 3/23/25.
//


import SwiftUI
import Firebase
import FirebaseFirestore

class SearchViewModel: ObservableObject {
//    const usersCollection = await Firestore.firestore().collection("users")
//    usersCollection.docs.map(doc => doc.data())
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
