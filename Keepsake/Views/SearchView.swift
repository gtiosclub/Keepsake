//
//  SearchView.swift
//  Keepsake
//
//  Created by Ishita on 3/23/25.
//
//
//import Foundation
//import SwiftUI
//import FirebaseFirestore
//import FirebaseAuth
//
//struct SearchView: View {
//    @State private var searchText = "" // The text entered in the search bar
//    @State private var users: [User] = []  // Array to store the filtered list of users
//    @State private var isLoading = false // Loading state for fetching data
//    @EnvironmentObject var viewModel: AuthViewModel
//    
//    private var db = Firestore.firestore()
//    
//    var body: some View {
//        VStack {
//            // Search Bar
//            HStack {
//                TextField("Search Friends", text: $searchText)
//                    .padding(10)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(8)
//                    .onChange(of: searchText) { _ in
//                        searchUsers()
//                    }
//                    .padding()
//                
//                if isLoading {
//                    ProgressView()
//                        .padding(.trailing)
//                }
//            }
//            
//            // Display the results
//            List(users) { user in
//                HStack {
//                    Text(user.name)
//                        .font(.headline)
//                    Spacer()
//                }
//            }
//        }
//        .navigationTitle("Community Search")
//    }
//    
//    private func searchUsers() {
//        guard !searchText.isEmpty else {
//            users = [] // Clear results when search text is empty
//            return
//        }
//        
//        isLoading = true
//        
//        // Perform the search query
//        db.collection("users") // Assuming your users are stored in Firestore under the "users" collection
//            .getDocuments { (snapshot, error) in
//                isLoading = false
//                if let error = error {
//                    print("Error fetching users: \(error)")
//                    return
//                }
//                
//                // Filter documents by name based on the search text
//                let allUsers = snapshot?.documents.compactMap { document -> User? in
//                    // Assuming the User model exists and can be initialized from Firestore
//                    guard let name = document.data()["name"] as? String else {
//                        return nil
//                    }
//                    return User(id: document.documentID, name: name, journalShelves: [], scrapbookShelves: [], savedTemplates: [])
//                } ?? []
//                
//                // Filter users by the searchText
//                self.users = allUsers.filter { user in
//                    user.name.lowercased().contains(searchText.lowercased()) // Case-insensitive search
//                }
//            }
//    }
//}

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search for a friend...", text: $viewModel.searchText)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 10)

                // User List
                List(viewModel.filteredUsers, id: \.id) { user in
                    HStack {
                        Image(systemName: "person.circle.fill") // Default user icon
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)

                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("@\(user.name.lowercased())") // Simulating a username
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle()) // Removes default list styling
            }
            .navigationTitle("Search Friends")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
