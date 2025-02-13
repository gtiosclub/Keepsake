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
//    @State var book: any Book
    @State var book: Journal
    @Binding var degrees: CGFloat
    @State var isHidden: Bool = false
    @Binding var show: Bool
    @State var displayDegrees: CGFloat = 0
    @State var frontDegrees: CGFloat = -180
    @State var zIndex: Double = -1
    @State var circleStart: CGFloat = 1
    @State var circleEnd: CGFloat = 1
    @State var displayPageIndex: Int
    @State var displayIsHidden: Bool = false
    @State var frontIsHidden: Bool = true
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
                .frame(width: UIScreen.main.bounds.width * 0.9 + 8, height: UIScreen.main.bounds.height * 0.55)
                .foregroundStyle(book.template.coverColor)
                .offset(x: 4, y: 7)
                .zIndex(-4)
            //Back Page
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                    .foregroundStyle(book.template.pageColor)
                    .offset(x: 5, y: 5)
                    .zIndex(-2)
                Text(displayPageIndex + 1 < book.pages.count && displayPageIndex + 1 > -1 ? "\(book.pages[displayPageIndex + 1].number)" : "no more pages")
            }
            //Display Page
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                    .zIndex(zIndex)
                    .foregroundStyle(book.template.pageColor)
                    .offset(x: 5, y: 5)
                Text(displayPageIndex < book.pages.count && displayPageIndex > -1 ? "\(book.pages[displayPageIndex].number)" : "no more pages")
                    .opacity(displayIsHidden ? 0 : 1)
            }.rotation3DEffect(.degrees(displayDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
            //Fake Front Page
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                .zIndex(0)
                .foregroundStyle(book.template.pageColor)
                .offset(x: 5, y: 5)
                .rotation3DEffect(.degrees(-180), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
            //Front Page
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                    .zIndex(0)
                    .foregroundStyle(book.template.pageColor)
                    .offset(x: 5, y: 5)
                Text(displayPageIndex - 1 < book.pages.count && displayPageIndex - 1 > -1 ? "\(book.pages[displayPageIndex - 1].number)" : "no more pages")
                    .opacity(frontIsHidden ? 0 : 1)
            }.rotation3DEffect(.degrees(frontDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.55)
                    .foregroundStyle(book.template.coverColor)
                Text(book.name)
                    .font(.title)
                    .foregroundStyle(book.template.titleColor)
                    .opacity(isHidden ? 0 : 1)
            }.rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
                .zIndex(degrees == -180 ? -1 : 0)
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .trim(from: 0.5, to: 1)
                                .stroke(lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.08)
                            Circle()
                                .trim(from: circleStart, to: circleEnd)
                                .stroke(book.template.pageColor, lineWidth: 3)
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
                    circleStart = 1
                    circleEnd = 1
                    zIndex = -0.5
                    withAnimation(.linear(duration: 1).delay(0.5)) {
                        displayDegrees -= 90
                        circleStart -= 0.25
                    } completion: {
                        circleStart = 0.5
                        circleEnd = 0.75
                        displayIsHidden = true
                        withAnimation(.linear(duration: 1).delay(0)) {
                            displayDegrees -= 90
                            circleEnd -= 0.25
                        } completion: {
                            displayDegrees = 0
                            displayPageIndex += 1
                            displayIsHidden = false
                        }
                    }
                }
                Button("Page Right"){
                    circleStart = 0.5
                    circleEnd = 0.5
                    withAnimation(.linear(duration: 1).delay(0.5)) {
                        frontDegrees += 90
                        circleEnd += 0.25
                    } completion: {
                        frontIsHidden = false
                        circleStart = 0.75
                        circleEnd = 1
                        withAnimation(.linear(duration: 1).delay(0)) {
                            frontDegrees += 90
                            circleStart += 0.25
                        } completion: {
                            displayPageIndex -= 1
                            frontDegrees = -180
                            frontIsHidden = true
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
            OpenJournal(book: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .red, pageColor: .gray, titleColor: .black), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]), degrees: $number, show: $show, displayPageIndex: 2)
        }
    }

    return Preview()
}
