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
    @ObservedObject var viewModel: FirebaseViewModel
    @ObservedObject var userVM: UserViewModel
    //@StateObject private var viewModel = UserLookupViewModel()
    var body: some View {
        NavigationStack {
            let newUser = viewModel.currentUser
            
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
                    }
                    .background(
                        NavigationLink(
                            destination: SearchedUserProfileView(currentUserID: newUser?.id ?? "", selectedUserID: user.id, userVM: userVM, viewModel: viewModel),
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
            isTextFieldFocused = true
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    UserSearchView(viewModel: FirebaseViewModel(), userVM: UserViewModel(user: User()))
}
