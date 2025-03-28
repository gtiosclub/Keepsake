//
//  SearchView.swift
//  Keepsake
//
//  Created by Ishita on 3/23/25.
//
//

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
