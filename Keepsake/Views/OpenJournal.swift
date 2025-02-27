//
//  Open Journal.swift
//  Keepsake
//
//  Created by Alec Hance on 2/11/25.
//

import SwiftUI

struct OpenJournal: View {
//    @State var book: any Book
    @State var book: Journal
    @Binding var degrees: CGFloat
    @Binding var isHidden: Bool
    @Binding var show: Bool
    @State var displayDegrees: CGFloat = 0
    @Binding var frontDegrees: CGFloat
    @State var zIndex: Double = -1
    @Binding var circleStart: CGFloat
    @Binding var circleEnd: CGFloat
    @State var displayPageIndex: Int
    @State var displayIsHidden: Bool = false
    @State var frontIsHidden: Bool = true
    @Binding var coverZ: Double
    @Binding var scaleFactor: CGFloat
    var body: some View {
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
                    }.frame(width: UIScreen.main.bounds.width * 0.87)
                }
            }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
            //Display Page
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
                    .zIndex(displayIsHidden ? 0 : zIndex)
                    .foregroundStyle(book.template.pageColor)
                    .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
                VStack {
                    if displayPageIndex < book.pages.count && displayPageIndex > -1 {
                        ForEach(book.pages[displayPageIndex].entries.indices, id: \.self) { index in
                            JournalTextWidgetView(entry: book.pages[displayPageIndex].entries[index])
                                .padding(.top, 10)
                                .opacity(displayIsHidden ? 0 : 1)
                        }
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text(displayPageIndex < book.pages.count && displayPageIndex > -1 ? "\(book.pages[displayPageIndex].number)" : "no more pages")
                    }
                }

            }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
            .rotation3DEffect(.degrees(displayDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
                .gesture(
                    DragGesture()
                        .onEnded({ value in
                            if value.translation.width < 0 {
                                circleStart = 0.5
                                circleEnd = 1
                                zIndex = -0.5
                                withAnimation(.linear(duration: 0.5).delay(0.5)) {
                                    displayDegrees -= 90
                                    circleEnd -= 0.25
                                } completion: {
                                    circleStart = 0.75
                                    circleEnd = 1
                                    displayIsHidden = true
                                    withAnimation(.linear(duration: 0.5).delay(0)) {
                                        displayDegrees -= 90
                                        circleStart -= 0.25
                                    } completion: {
                                        displayDegrees = 0
                                        displayPageIndex += 1
                                        displayIsHidden = false
                                    }
                                }
                            }

                            if value.translation.width > 0 {
                                // right
                                circleStart = 0.5
                                circleEnd = 1
                                withAnimation(.linear(duration: 0.5).delay(0.5)) {
                                    frontDegrees += 90
                                    circleStart += 0.25
                                } completion: {
                                    frontIsHidden = false
                                    circleStart = 0.5
                                    circleEnd = 0.75
                                    withAnimation(.linear(duration: 0.5).delay(0)) {
                                        frontDegrees += 90
                                        circleEnd += 0.25
                                    } completion: {
                                        displayPageIndex -= 1
                                        frontDegrees = -180
                                        frontIsHidden = true
                                    }
                                }
                            }
                        })
                    )
              
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
                    }
                }
//                    .opacity(frontIsHidden ? 0 : 1)
            }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
                .rotation3DEffect(.degrees(frontDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
            //Cover page
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
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .trim(from: circleStart, to: circleEnd)
                                .stroke(lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.08)
                                .opacity(isHidden ? 1 : 0)
//                            Circle()
//                                .trim(from: circleStart, to: circleEnd)
//                                .stroke(coverZ != 0 ? book.template.pageColor : book.template.coverColor, lineWidth: 3)
//                                .frame(width: UIScreen.main.bounds.width * 0.08)
                            
                        }.frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.04)
                        
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.45)
            HStack {
                Button(action: {
                    circleStart = 0.5
                    circleEnd = 1
                    withAnimation(.linear(duration: 1).delay(0.5)) {
                        circleStart += 0.25
                        degrees += 90
                        frontDegrees += 90
                    } completion: {
                        coverZ = 0
                        isHidden = false
                        withAnimation {
                            circleStart += 0.25
                            degrees += 90
                            frontDegrees += 90
                        } completion: {
                            withAnimation(.linear(duration: 0.7)) {
                                scaleFactor = 0.6
                            } completion: {
                                withAnimation {
                                    show.toggle()
                                }
                            }
                        }
                    }
                }, label: {
                    Image(systemName: "return")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.1)
                }).opacity(degrees == -180 ? 1 : 0)
                Spacer()
                AddEntryButtonView()
                    .opacity(degrees == -180 ? 1 : 0)
            }.padding(.horizontal, 20).offset(y: UIScreen.main.bounds.height * 0.33)
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
        @State var number2: CGFloat = -180
        @State var show: Bool = true
        @State var cover: Double = -2
        @State var circleStart: CGFloat = 0.5
        @State var circleEnd: CGFloat = 1
        @State var scaleFactor: CGFloat = 0.6
        @State var isHidden: Bool = true
        @State var mainCircleStart: CGFloat = 0.5
        var body: some View {
            OpenJournal(book: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")]), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")]), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")]), JournalPage(number: 5, entries: [])]), degrees: $number, isHidden: $isHidden, show: $show, frontDegrees: $number2, circleStart: $circleStart, circleEnd: $circleEnd, displayPageIndex: 2, coverZ: $cover, scaleFactor: $scaleFactor)
        }
    }

    return Preview()
}
