//
//  BookshelfForScrapbookView.swift
//  Keepsake
//
//  Created by Ganden Fung on 3/12/25.
//


import SwiftUI


struct BookshelfForScrapbookView: View {
    var shelf: ScrapbookShelf
    @State var scale: CGFloat = 0.24
    var body: some View {
        VStack(alignment: .leading) {
            Text(shelf.name)
                .font(.headline)
                .padding(.leading, 8)
                .padding(.top, 8)
            
            HStack {
                if !shelf.scrapbooks.isEmpty {
                    // Placeholder to maintain height and width
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.2))
//                        .frame(height: 100)
//                        .cornerRadius(8)
//                        .padding(.horizontal)
//                        .padding(.vertical)
                    ForEach(shelf.scrapbooks.indices, id: \.self) { index in
                        JournalSpine(book: shelf.scrapbooks[index], degrees: 0)
                            .scaleEffect(scale)
                            .frame(width: scale * UIScreen.main.bounds.width * 0.4, height: scale * UIScreen.main.bounds.height * 0.56)
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

#Preview {
    BookshelfForScrapbookView(shelf: ScrapbookShelf(name: "Bookshelf", scrapbooks: [
        Scrapbook(name: "Scrapbook 1", createdDate: "2/2/25", entries: [
            ScrapbookEntry(id: "1", imageURL: "image1.jpg", caption: "Trip to the mountains", date: "03/04/25"),
            ScrapbookEntry(id: "2", imageURL: "image2.jpg", caption: "Beach sunset", date: "03/04/25")
        ], category: "travel", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather)),
        
        Scrapbook(name: "Scrapbook 2", createdDate: "2/3/25", entries: [
            ScrapbookEntry(id: "3", imageURL: "image3.jpg", caption: "Birthday party", date: "03/05/25")
        ], category: "events", isSaved: true, isShared: true, template: Template(name: "Template 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather)),
        
        Scrapbook(name: "Scrapbook 3", createdDate: "2/4/25", entries: [], category: "misc", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather)),
        
        Scrapbook(name: "Scrapbook 4", createdDate: "2/5/25", entries: [
            ScrapbookEntry(id: "4", imageURL: "image4.jpg", caption: "Graduation day", date: "03/06/25"),
            ScrapbookEntry(id: "5", imageURL: "image5.jpg", caption: "Family reunion", date: "03/07/25")
        ], category: "family", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather))
    ]))
}
