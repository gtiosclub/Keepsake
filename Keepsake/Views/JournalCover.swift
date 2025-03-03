//
//  JournalCover.swift
//  Keepsake
//
//  Created by Alec Hance on 2/10/25.
//


import SwiftUI

struct JournalCover: View {
    @State var book: any Book
//    @Binding var degrees: CGFloat
    @State var degrees: CGFloat
    var body: some View {
        ZStack {
            // Spine Effect
            Rectangle()
                .fill(book.template.coverColor) // Darker than cover color
                .brightness(-0.2)
                .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
                .offset(x: UIScreen.main.bounds.width * -0.42)
                .shadow(radius: 3)
                .zIndex(-3)
                .overlay(
                    Image("\(book.template.texture)") // Load texture image from assets
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
                        .offset(x: UIScreen.main.bounds.width * -0.42)
                        .scaledToFill()
                        .opacity(0.4) // Adjust for realism
                )
            
//            // Page Thickness Simulation (Right Edge)
//            Rectangle()
//                .fill(Color.gray.opacity(0.8))
//                .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.54)
//                .offset(x: UIScreen.main.bounds.width * 0.46)
//                .shadow(radius: 2)
//                .zIndex(-3)
            
            // Cover Page
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(book.template.coverColor)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
                    .overlay(
                        Image("\(book.template.texture)") // Load texture image from assets
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .scaledToFill()
                            .opacity(0.4) // Adjust for realism
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 5, y: 5) // Gives depth
                
                // Title
                Text(book.name)
                    .font(.title)
                    .foregroundStyle(book.template.titleColor)
            }
            .rotation3DEffect(.degrees(0), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
        }
    }
}
#Preview {
    JournalCover(book: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .red, pageColor: .white, titleColor: .black), pages: []), degrees: 0)
}

//Color(red: 0.96, green: 0.5, blue: 0.5)
//Color(red: 0.96, green: 0.95, blue: 0.78)

