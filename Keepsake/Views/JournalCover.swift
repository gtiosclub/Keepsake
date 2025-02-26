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
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        BottomLeftSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.02).padding(.top, UIScreen.main.bounds.height * 0.02)
                    }
                }
            }.offset(x: UIScreen.main.bounds.width * -0.45)
                .zIndex(-100)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.9 + 8, height: UIScreen.main.bounds.height * 0.56)
                .foregroundStyle(book.template.coverColor)
                .offset(x: UIScreen.main.bounds.height * 0.004, y: 0)
                .zIndex(-4)
            //Display Page
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                    .foregroundStyle(book.template.pageColor)
                    .offset(x: 5, y: 0)
            }
            
            //Cover page
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
                    .foregroundStyle(book.template.coverColor)
                Text(book.name)
                    .font(.title)
                    .foregroundStyle(book.template.titleColor)
//                    .opacity(isHidden ? 0 : 1)
            }.rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .trim(from: 0.5, to: 1)
                                .stroke(lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.08)
                            BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.02)
                                .offset(y: -UIScreen.main.bounds.height * 0.02)
                        }.frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.04)
                        
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.45)
            
                
            }
        }
}
#Preview {
    JournalCover(book: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .green, pageColor: .white, titleColor: .black), pages: []), degrees: 0)
}

//Color(red: 0.96, green: 0.5, blue: 0.5)
//Color(red: 0.96, green: 0.95, blue: 0.78)

