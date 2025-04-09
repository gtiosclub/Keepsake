//
//  UserSearchView.swift
//  Keepsake
//
//  Created by Nithya Ravula on 3/28/25.
//

import SwiftUI

struct UserSearchView: View {
    @State private var selectedUserID: String?
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText = ""
    @StateObject var firebaseViewModel = FirebaseViewModel()
    @StateObject private var viewModel = UserLookupViewModel()
    @State private var currentUserFriends: [String] = []
    
    var body: some View {
        NavigationStack {
            let newUser = firebaseViewModel.currentUser
            
            VStack {
                HStack {
                    
                    
                    HStack {
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for users...", text: $searchText, onCommit: {
                            viewModel.searchUsers(searchText: searchText, currentUserName: newUser?.username ?? "")
                        })                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .focused($isTextFieldFocused)
                            .onChange(of: searchText) { newValue in
                                viewModel.searchUsers(searchText: newValue, currentUserName: newUser?.username ?? "")
                            }
                        
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        
                            Text("Cancel")
                                .foregroundColor(.pink)
                        
                    }
                    .padding(.trailing)
                    .padding(.leading, -10)
                }
                List(viewModel.users) { user in
                    HStack {
                        Button(action: {
                            selectedUserID = user.id
                        }) {
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.username)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Spacer()
                        Button(action: {
                            guard let currentUserID = newUser?.id else { return }

                            if currentUserFriends.contains(user.id) {
                                currentUserFriends.removeAll { $0 == user.id }
                                viewModel.removeFriend(currentUserID: currentUserID, friendUserID: user.id)
                            } else {
                                currentUserFriends.append(user.id)
                                viewModel.addFriend(currentUserID: currentUserID, friendUserID: user.id)
                            }
                        }) {
                            Text(currentUserFriends.contains(user.id) ? "Remove Friend" : "Add Friend")
                                .foregroundColor(.pink)
                        }
                        
//                        Button(action: {
//                            guard let currentUserID = newUser?.id else { return }
//
//                            if currentUserFriends.contains(user.id) {
//                                // Remove friend locally
//                                if let index = viewModel.users.firstIndex(where: { $0.id == currentUserID }) {
//                                    viewModel.users[index].friends.removeAll { $0 == user.id }
//                                }
//                                viewModel.removeFriend(currentUserID: currentUserID, friendUserID: user.id)
//                            } else {
//                                // Add friend locally
//                                if let index = viewModel.users.firstIndex(where: { $0.id == currentUserID }) {
//                                    viewModel.users[index].friends.append(user.id)
//                                }
//                                viewModel.addFriend(currentUserID: currentUserID, friendUserID: user.id)
//                            }
//                        }) {
//                            Text(newUser!.friends.contains(user.id) ? "Remove Friend" : "Add Friend")
//                                .foregroundColor(.pink)
//                        }
                    }
                    .background(
                        NavigationLink(
                            destination: SearchedUserProfileView(currentUserID: newUser!, selectedUserID: user.id,
                                    friends: $currentUserFriends),
                            tag: user.id,
                            selection: $selectedUserID
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    )
                }
                .listStyle(PlainListStyle())


            }
            
            
        }
        .onAppear {
            if let currentUser = firebaseViewModel.currentUser {
                            currentUserFriends = currentUser.friends
                        }
            isTextFieldFocused = true
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    UserSearchView()
}
