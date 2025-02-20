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
                ForEach(shelf.books.indices, id: \.self) { _ in
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(width: 40, height: 100)
//                        .cornerRadius(4)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 100)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.vertical)
                }
            }
            .background(Color.white)
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

