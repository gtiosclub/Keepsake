//
//  BookshelfView.swift
//  Keepsake
//
//  Created by Connor on 2/12/25.
//

import SwiftUI


struct BookshelfView: View {
    var shelf: Shelf
    var body: some View {
        VStack(alignment: .leading) {
            Text(shelf.name)
                .font(.headline)
                .padding(.leading, 8)
                .padding(.top, 8)
            
            HStack {
                if !shelf.books.isEmpty {
                    // Placeholder to maintain height and width
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.2))
//                        .frame(height: 100)
//                        .cornerRadius(8)
//                        .padding(.horizontal)
//                        .padding(.vertical)
                    ForEach(shelf.books.indices, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 100)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .padding(.vertical)
                    }
                }
//                else {
//                    ForEach(shelf.books.indices, id: \.self) { _ in
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.3))
//                            .frame(height: 100)
//                            .cornerRadius(8)
//                            .padding(.horizontal)
//                            .padding(.vertical)
//                    }
//                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color.white)
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

