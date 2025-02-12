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
                        LeftSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.01)
                        BottomLeftSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.005)
                        
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.25)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.5 + 8, height: UIScreen.main.bounds.height * 0.3)
                .foregroundStyle(book.template.coverColor)
                .offset(x: 4, y: 7)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.3)
                .foregroundStyle(book.template.pageColor)
                .offset(x: 5, y: 5)
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        RightSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.01)
                        BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.005)
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.24)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.3)
                    .foregroundStyle(book.template.coverColor)
                Text(book.name)
                    .font(.title)
                    .foregroundStyle(book.template.titleColor)
                VStack {
                    ForEach(0..<9, id: \.self) { i in
                        VStack(spacing: 0) {
                            RightSemi().stroke(Color.black, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.01)
                            BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.005)
                            
                        }
                        
                        
                    }
                }.offset(x: UIScreen.main.bounds.width * -0.24)
                
            }.rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
        }
    }
}
//#Preview {
//    JournalCover(book: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .green, pageColor: .white, titleColor: .black)), degrees: 0)
//}

//Color(red: 0.96, green: 0.5, blue: 0.5)
//Color(red: 0.96, green: 0.95, blue: 0.78)

