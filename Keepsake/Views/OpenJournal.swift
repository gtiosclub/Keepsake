//
//  Open Journal.swift
//  Keepsake
//
//  Created by Alec Hance on 2/11/25.
//

import SwiftUI

struct LeftSemi: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          control: CGPoint(x: rect.minX, y:  rect.minY))
        
        return path

    }
}

struct RightSemi: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY),
                          control: CGPoint(x: rect.maxX, y:  rect.minY))
        
        return path

    }
}

struct BottomLeftSemi: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                          control: CGPoint(x: rect.minX, y:  rect.maxY))
        
        return path

    }
}

struct OpenJournal: View {
    @State var book: any Book
    @Binding var degrees: CGFloat
    @State var isHidden: Bool = false
    var body: some View {
        ZStack {
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        LeftSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.02)
                        BottomLeftSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.01)
                        
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.45)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.9 + 8, height: UIScreen.main.bounds.height * 0.55)
                .foregroundStyle(book.template.coverColor)
                .offset(x: 4, y: 7)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                .foregroundStyle(book.template.pageColor)
                .offset(x: 5, y: 5)
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        RightSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.02)
                        BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.01)
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.43)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                    .foregroundStyle(book.template.coverColor)
                Text(book.name)
                    .font(.title)
                    .foregroundStyle(book.template.titleColor)
                    .opacity(isHidden ? 0 : 1)
                VStack {
                    ForEach(0..<9, id: \.self) { i in
                        VStack(spacing: 0) {
                            RightSemi().stroke(Color.black, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.02)
                            BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.01)
                            
                        }
                        
                        
                    }
                }.offset(x: UIScreen.main.bounds.width * -0.43)
                
            }.rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
        }
    }
}
//
//#Preview {
//    OpenJournal(book: shelf.books[number], degrees: $degrees)
//}

#Preview {
    struct Preview: View {
        @State var number: CGFloat = -180.0
        var body: some View {
            OpenJournal(book: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black)), degrees: $number)
        }
    }

    return Preview()
}
