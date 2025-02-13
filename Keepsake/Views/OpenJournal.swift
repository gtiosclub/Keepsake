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
    @Binding var show: Bool
    @State var degreesPageOne: CGFloat = 0
    @State var zIndex: Double = -1
    @State var circleStart: CGFloat = 1
    @State var circleEnd: CGFloat = 1
    @State var animationColor: Color = .gray
    var body: some View {
        ZStack {
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            LeftSemi().stroke(Color.clear, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.02)
                            RightSemi().stroke(Color.clear, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.02)
                        }
                        BottomLeftSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.02)
                        
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.45)
                .zIndex(-100)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.9 + 8, height: UIScreen.main.bounds.height * 0.55)
                .foregroundStyle(book.template.coverColor)
                .offset(x: 4, y: 7)
                .zIndex(-4)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                .foregroundStyle(.yellow)
                .offset(x: 5, y: 5)
                .zIndex(-2)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                .zIndex(zIndex)
                .foregroundStyle(book.template.pageColor)
                .offset(x: 5, y: 5)
                .rotation3DEffect(.degrees(degreesPageOne), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
//                        RightSemi().stroke(Color.black, lineWidth: 2)
//                            .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.02)
//                        BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
//                            .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.01)
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
//                            RightSemi().stroke(Color.black, lineWidth: 2)
//                                .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.02)
//                            BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
//                                .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.01)
                            
                        }
                        
                        
                    }
                }.offset(x: UIScreen.main.bounds.width * -0.43)
            }.rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
                .zIndex(degrees == -180 ? -1 : 0)
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        ZStack {
//                            HStack(spacing: 0) {
//                                LeftSemi().stroke(Color.black, lineWidth: 2)
//                                    .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.02)
//                                RightSemi().stroke(Color.black, lineWidth: 2)
//                                    .frame(width: UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.height * 0.02)
//                            }
                            Circle()
                                .trim(from: 0.5, to: 1)
                                .stroke(lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.08)
                            Circle()
                                .trim(from: circleStart, to: circleEnd)
                                .stroke(animationColor, lineWidth: 3)
                                .frame(width: UIScreen.main.bounds.width * 0.08)
                            
                            BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.02)
                                .offset(y: -UIScreen.main.bounds.height * 0.02)
                        }.frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.04)
                        
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.45)
            HStack {
                Button("Back") {
                    withAnimation(.linear(duration: 1).delay(0.5)) {
                        degrees += 180
                    } completion: {
                        withAnimation {
                            show.toggle()
                        }
                    }
                }
                Button("Page left") {
                    zIndex = -0.5
                    withAnimation(.linear(duration: 1).delay(0.5)) {
                        degreesPageOne -= 90
                        circleStart -= 0.25
                    } completion: {
                        circleStart = 0.5
                        circleEnd = 0.75
                        withAnimation(.linear(duration: 1).delay(0)) {
                            degreesPageOne -= 90
                            circleEnd -= 0.25
                        }
                    }
                }
                Button("Page Right"){
                    withAnimation(.linear(duration: 1).delay(0.5)) {
                        degreesPageOne += 90
                        circleEnd += 0.25
                    } completion: {
                        circleStart = 0.75
                        circleEnd = 1
                        withAnimation(.linear(duration: 1).delay(0)) {
                            degreesPageOne += 90
                            circleStart += 0.25
                        }
                    }
                }
                
            }.offset(y: 280)
        }
    }
}
//
//#Preview {
//    OpenJournal(book: shelf.books[number], degrees: $degrees)
//}

#Preview {
    struct Preview: View {
        @State var number: CGFloat = -180
        @State var show: Bool = true
        var body: some View {
            OpenJournal(book: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .red, pageColor: .gray, titleColor: .black)), degrees: $number, show: $show)
        }
    }

    return Preview()
}
