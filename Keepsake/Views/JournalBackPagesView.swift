//
//  JournalBackPagesView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/28/25.
//

import SwiftUI

struct JournalBackPagesView: View {
    var book: Journal
    @Binding var displayPageIndex: Int
    @Binding var degrees: CGFloat
    var body: some View {
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
            .zIndex(-4)
        //Back Page
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
                .foregroundStyle(book.template.pageColor)
                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
                .zIndex(-2)
            VStack {
                if displayPageIndex + 1 < book.pages.count && displayPageIndex - 1 > -1{
                    ForEach(book.pages[displayPageIndex + 1].entries.indices, id: \.self) { index in
                        JournalTextWidgetView(entry: book.pages[displayPageIndex + 1].entries[index])
                            .padding(.top, 10)
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(displayPageIndex + 1 < book.pages.count && displayPageIndex > -1 ? "\(book.pages[displayPageIndex + 1].number)" : "no more pages")
                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
                        .opacity(degrees == 0 ? 0 : 1)
                }.frame(width: UIScreen.main.bounds.width * 0.87)
            }
        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
    }
}

