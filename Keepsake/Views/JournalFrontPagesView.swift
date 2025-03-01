//
//  JournalFrontPagesView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/28/25.
//

import SwiftUI

struct JournalFrontPagesView: View {
    var book: Journal
    @Binding var degrees: CGFloat
    @Binding var frontIsHidden: Bool
    @Binding var displayPageIndex: Int
    @Binding var frontDegrees: CGFloat
    @Binding var isHidden: Bool
    @Binding var coverZ: Double
    var body: some View {
        //Fake Front Page
        RoundedRectangle(cornerRadius: 10)
            .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
            .zIndex(0)
            .foregroundStyle(book.template.pageColor)
            .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
            .rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
        //Front Page
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
                .zIndex(0)
                .foregroundStyle(book.template.pageColor)
                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
            VStack {
                if displayPageIndex - 1 < book.pages.count && displayPageIndex - 1 > -1 {
                    ForEach(book.pages[displayPageIndex - 1].entries.indices, id: \.self) { index in
                        JournalTextWidgetView(entry: book.pages[displayPageIndex - 1].entries[index])
                            .padding(.top, 10)
                            .opacity(frontIsHidden ? 0 : 1)
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(displayPageIndex - 1 < book.pages.count && displayPageIndex > -1 ? "\(book.pages[displayPageIndex - 1].number)" : "no more pages")
                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
                }
            }
            //                    .opacity(frontIsHidden ? 0 : 1)
        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
            .rotation3DEffect(.degrees(frontDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
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
                .shadow(color: .black.opacity(degrees > -180 ? 0 : 0.3), radius: 5, x: 5, y: 5) // Gives depth
            
            // Title
            Text(book.name)
                .font(.title)
                .foregroundStyle(book.template.titleColor)
                .opacity(isHidden ? 0 : 1)
            Rectangle()
                .fill(book.template.coverColor) // Darker than cover color
                .brightness(-0.2)
                .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
                .offset(x: UIScreen.main.bounds.width * -0.42)
                .shadow(radius: 3)
                .opacity(isHidden ? 0 : 1)
                .zIndex(-3)
                .overlay(
                    Image("\(book.template.texture)") // Load texture image from assets
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
                        .offset(x: UIScreen.main.bounds.width * -0.42)
                        .scaledToFill()
                        .opacity(isHidden ? 0 : 0.4) // Adjust for realism
                )
        }.rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
            .zIndex(coverZ)
    }
}

