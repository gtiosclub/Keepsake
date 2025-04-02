//
//  BookshelfView.swift
//  Keepsake
//
//  Created by Connor on 2/12/25.
//

import SwiftUI


struct BookshelfView: View {
    @ObservedObject var shelf: JournalShelf
    @State var scale: CGFloat = 0.24
    let isEven: Bool
    let angles: [Double] = [0, 0, -2, -10, -30]
    @State var isEditing: Bool = false
    @State var editedName: String = ""
    @ObservedObject var fbVM: FirebaseViewModel
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .frame(height: 150)
                .cornerRadius(10)
                .shadow(radius: 2)

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
            ForEach(shelf.journals.indices, id: \.self) { index in
                let angle = isEven ? angles[index % angles.count] : -1 * angles[(angles.count - index - 1) % angles.count]
                let spacing = abs(angle) * 0.8

                JournalSpine(book: shelf.journals[index], degrees: angle)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(angle))
                    .offset(x: isEven ? spacing : -1 * spacing, y: 0)
                    .frame(width: scale * UIScreen.main.bounds.width * 0.4, height: scale * UIScreen.main.bounds.height * 0.56)
            }
        }
        .padding(.leading, isEven ? 4 : 0)
        .padding(.trailing, isEven ? 0 : 4)
    }

    var textSection: some View {
        HStack {
            if isEditing {
                TextField("Enter name", text: $editedName, onCommit: {
                    shelf.name = editedName
                    isEditing = false
                    Task {
                        await fbVM.updateShelfName(shelfID: shelf.id, newName: editedName)
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 150)
            } else {
                Text(shelf.name)
                    .font(.headline)
            }
            
            Button(action: {
                isEditing.toggle()
                if isEditing {
                    editedName = shelf.name
                }
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.black)
            }
        }.frame(height: scale * UIScreen.main.bounds.height * 0.56, alignment: .top)
            .padding(.leading, isEven ? 0 : 4)
            .padding(.trailing, isEven ? 4 : 0)
    }
}

#Preview {
    BookshelfView(shelf: JournalShelf(name: "Bookshelf", journals: [
    ]), isEven: true, fbVM: FirebaseViewModel())
}
