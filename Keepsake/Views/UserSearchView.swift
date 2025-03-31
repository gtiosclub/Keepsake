//
//  UserSearchView.swift
//  Keepsake
//
//  Created by Nithya Ravula on 3/28/25.
//

import SwiftUI

struct UserSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText = ""
    @StateObject private var viewModel = UserLookupViewModel()
    var body: some View {
        NavigationStack {
            
            VStack {
                HStack {
                    
                    
                    HStack {
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for users...", text: $searchText, onCommit: {
                            viewModel.searchUsers(searchText: searchText)
                        })                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .focused($isTextFieldFocused)
                            .onChange(of: searchText) { newValue in
                                viewModel.searchUsers(searchText: newValue)
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
                    Button(action: {
                        print(user.id)
                    }) {
                        VStack(alignment: .leading) {
                            
                            Text(user.name)
                                .font(.headline)
                            Text(user.username)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    
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
    UserSearchView()
}
