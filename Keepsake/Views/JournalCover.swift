//
//  JournalCover.swift
//  Keepsake
//
//  Created by Alec Hance on 2/10/25.
//

import SwiftUI

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

struct JournalCover: View {
    @State var journal: Journal
//    @State var coverColor: Color
//    @State var pageColor: Color
//    @State var titleText: String
//    @State var titleColor: Color
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
                .foregroundStyle(journal.template.coverColor)
                .offset(x: 4, y: 7)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.3)
                .foregroundStyle(journal.template.pageColor)
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
                    .foregroundStyle(journal.template.coverColor)
                Text(journal.name)
                    .font(.title)
                    .foregroundStyle(journal.template.titleColor)
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
                
            }
        }
    }
}
#Preview {
    JournalCover(journal: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .green, pageColor: .white, titleColor: .black)))
}

//Color(red: 0.96, green: 0.5, blue: 0.5)
//Color(red: 0.96, green: 0.95, blue: 0.78)

