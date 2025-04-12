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

                            Task {
                                guard let currentUserID = newUser?.id else { return }

                                if firebaseViewModel.currentUser?.friends.contains(user.id) == true {
                                    viewModel.removeFriend(currentUserID: currentUserID, friendUserID: user.id)
                                } else {
                                    viewModel.addFriend(currentUserID: currentUserID, friendUserID: user.id)
                                }

                                await firebaseViewModel.fetchUser()
                            }
                        }) {
                            Text((firebaseViewModel.currentUser?.friends.contains(user.id) == true) ? "Remove Friend" : "Add Friend")
                                .foregroundColor(.pink)
                        }
                        

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
            Task {
                        await firebaseViewModel.fetchUser()
                    }
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
