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
        HStack(spacing: 0) {
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
                        await fbVM.updateShelfName(shelfID: shelf.id, newName: editedName)
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 150)
            } else {
                Text(shelf.name)
                    .font(.system(size: 25, weight: .semibold))
                
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

#Preview {
    BookshelfView(shelf: JournalShelf(name: "Bookshelf", journals: [
    ]), isEven: true, fbVM: FirebaseViewModel())
}
