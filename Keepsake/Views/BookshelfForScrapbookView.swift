//
//  BookshelfForScrapbookView.swift
//  Keepsake
//
//  Created by Ganden Fung on 3/12/25.
//


import SwiftUI


struct BookshelfForScrapbookView: View {
    @ObservedObject var shelf: ScrapbookShelf
    @State var scale: CGFloat = 0.24
    let isEven: Bool
    let angles: [Double] = [0, 0, -2, -10, -30]
    @State var isEditing: Bool = false
    @State var editedName: String = ""
    @ObservedObject var fbVM: FirebaseViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill()
                RoundedRectangle(cornerRadius: 20)
                        .fill(.shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 0, y: 0)))
                        .mask {
                            LinearGradient(
                                colors: [.clear, .black],
                                startPoint: UnitPoint(x: 0.5, y: 0.7),
                                endPoint: UnitPoint(x: 0.5, y: 0.9)
                            )
                        }
                RoundedRectangle(cornerRadius: 20)
                        .fill(.shadow(.inner(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)))
                        .mask {
                            LinearGradient(
                                colors: [.black, .clear],
                                startPoint: UnitPoint(x: 0.5, y: 0.1),
                                endPoint: UnitPoint(x: 0.5, y: 0.6)
                            )
                        }
                }
                .foregroundStyle(Color(white: 0.95))
                .frame(height: 150)

            HStack(alignment: .bottom) {
                if isEven {
                    booksSection
                    Spacer()
                    textSection
                } else {
                    textSection
                    Spacer()
                    booksSection
                }
            }
            .padding(.bottom, 2)
            .frame(height: 120)
        }
        .frame(height: 150)
    }
    
    var booksSection: some View {
        HStack(spacing: 2) {
            ForEach(shelf.scrapbooks.indices, id: \.self) { index in
                let angle = isEven ? angles[index % angles.count] : -1 * angles[(angles.count - index - 1) % angles.count]
                let spacing = abs(angle) * 0.8

                JournalSpine(book: shelf.scrapbooks[index], degrees: angle)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(angle))
                    .offset(x: isEven ? spacing : -1 * spacing, y: 0)
                    .frame(width: scale * UIScreen.main.bounds.width * 0.4,
                           height: scale * UIScreen.main.bounds.height * 0.56)
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 4, y: 4)
            }
        }
        .padding(.leading, isEven ? 9 : 0)
        .padding(.trailing, isEven ? 0 : 9)
    }

    var textSection: some View {
        HStack {
            if isEditing {
                TextField("Enter name", text: $editedName, onCommit: {
                    shelf.name = editedName
                    isEditing = false
                    Task {
                        await fbVM.updateScrapbookShelfName(shelfID: shelf.id, newName: editedName)
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 150)
            } else {
                Text(shelf.name)
                    .font(.system(size: 30, weight: .semibold))
                
            }
        }
        .frame(height: scale * UIScreen.main.bounds.height * 0.56, alignment: .top)
        .padding(.leading, isEven ? 0 : 10)
        .padding(.trailing, isEven ? 10 : 0)
        .offset(y: -20)
        .onTapGesture(count: 2) { // Detect double tap
            isEditing.toggle()
            if isEditing {
                editedName = shelf.name
            }
        }
    }
}
//#Preview {
//    BookshelfForScrapbookView(shelf: ScrapbookShelf(id: UUID(), name: "Bookshelf", scrapbooks: [
//        Scrapbook(name: "Scrapbook 1", createdDate: "2/2/25", entries: [
//            ScrapbookEntry(id: "1", imageURL: "image1.jpg", caption: "Trip to the mountains", date: "03/04/25"),
//            ScrapbookEntry(id: "2", imageURL: "image2.jpg", caption: "Beach sunset", date: "03/04/25")
//        ], category: "travel", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather)),
//        
//        Scrapbook(name: "Scrapbook 2", createdDate: "2/3/25", entries: [
//            ScrapbookEntry(id: "3", imageURL: "image3.jpg", caption: "Birthday party", date: "03/05/25")
//        ], category: "events", isSaved: true, isShared: true, template: Template(name: "Template 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather)),
//        
//        Scrapbook(name: "Scrapbook 3", createdDate: "2/4/25", entries: [], category: "misc", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather)),
//        
//        Scrapbook(name: "Scrapbook 4", createdDate: "2/5/25", entries: [
//            ScrapbookEntry(id: "4", imageURL: "image4.jpg", caption: "Graduation day", date: "03/06/25"),
//            ScrapbookEntry(id: "5", imageURL: "image5.jpg", caption: "Family reunion", date: "03/07/25")
//        ], category: "family", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather))
//    ]))
//}
