//
//  LibraryView.swift
//  Keepsake
//
//  Created by Connor on 2/12/25.
//


import SwiftUI

struct LibraryView: View {
//    let bookshelves = ["2025", "2024", "2023", "2022"]
    @ObservedObject var user: User
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(user.shelves.indices, id: \.self) { index in
                        BookshelfView(shelf: user.shelves[index])
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.gray.opacity(0.1))
            .navigationTitle("Your Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { /* Add bookshelf action */ }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUser = User(id: "1", name: "Sample User", shelves: [
            Shelf(name: "2025", books: [Journal(name: "Journal A", createdDate: "2023-01-01", entries: [], category: "Personal", isSaved: true, isShared: false, template: Template()), Journal(name: "Journal B", createdDate: "2023-01-01", entries: [], category: "Work", isSaved: true, isShared: false, template: Template())]),
            Shelf(name: "2024", books: [Scrapbook(name: "Scrapbook B", createdDate: "2022-06-15", entries: [], category: "Travel", isSaved: true, isShared: true, template: Template())])
        ])
        
        return LibraryView(user: sampleUser)
    }
}
