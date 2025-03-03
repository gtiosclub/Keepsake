//////
//////  Open Journal.swift
//////  Keepsake
//////
//////  Created by Alec Hance on 2/11/25.
//////
////
////import SwiftUI
////
////struct OpenJournal: View {
////    @Namespace private var openJournalNamespace
//////    @State var book: any Book
////    @ObservedObject var userVM: UserViewModel
////    @ObservedObject var journal: Journal
////    @State var shelfIndex: Int
////    @State var bookIndex: Int
////    @Binding var degrees: CGFloat
////    @Binding var isHidden: Bool
////    @Binding var show: Bool
////    @State var displayDegrees: CGFloat = 0
////    @Binding var frontDegrees: CGFloat
////    @State var zIndex: Double = -1
////    @Binding var circleStart: CGFloat
////    @Binding var circleEnd: CGFloat
////    @Binding var displayPageIndex: Int
////    @State var displayIsHidden: Bool = false
////    @State var frontIsHidden: Bool = true
////    @Binding var coverZ: Double
////    @Binding var scaleFactor: CGFloat
////    @Binding var inTextEntry: Bool
////    @State var entryIndex = -1
////    @State var scaleFactor2 = 0
////    @Binding var selectedEntry: Int
////    @Binding var showNavBack: Bool
////    var body: some View {
////        ZStack {
////            JournalBackPagesView(book: journal, displayPageIndex: $displayPageIndex, degrees: $degrees)
////            JournalDisplayView(displayIsHidden: $displayIsHidden, userVM: userVM, journal: journal, shelfIndex: shelfIndex, bookIndex: bookIndex, displayPageIndex: $displayPageIndex, zIndex: $zIndex, displayDegrees: $displayDegrees, circleStart: $circleStart, circleEnd: $circleEnd, frontIsHidden: $frontIsHidden, frontDegrees: $frontDegrees, inTextEntry: $inTextEntry, selectedEntry: $selectedEntry)
////            
////            JournalFrontPagesView(book: journal, degrees: $degrees, frontIsHidden: $frontIsHidden, displayPageIndex: $displayPageIndex, frontDegrees: $frontDegrees, isHidden: $isHidden, coverZ: $coverZ)
////            VStack {
////                ForEach(0..<9, id: \.self) { i in
////                    VStack(spacing: 0) {
////                        ZStack {
////                            Circle()
////                                .trim(from: circleStart, to: circleEnd)
////                                .stroke(lineWidth: 2)
////                                .frame(width: UIScreen.main.bounds.width * 0.08)
////                                .opacity(isHidden ? 1 : 0)
////                            
////                        }.frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.04)
////                        
////                    }
////                    
////                    
////                }
////            }.offset(x: UIScreen.main.bounds.width * -0.45)
////            HStack {
////
//<<<<<<< HEAD
////                Button(action: {
////                    circleStart = 0.5
////                    circleEnd = 1
////                    withAnimation(.linear(duration: 1).delay(0.5)) {
////                        circleStart += 0.25
////                        degrees += 90
////                        frontDegrees += 90
////                    } completion: {
////                        coverZ = 0
////                        isHidden = false
////                        withAnimation {
////                            circleStart += 0.25
////                            degrees += 90
////                            frontDegrees += 90
////                        } completion: {
////                            withAnimation(.linear(duration: 0.7)) {
////                                scaleFactor = 0.6
////                            } completion: {
////                                showNavBack.toggle()
////                                withAnimation {
////                                    show.toggle()
////                                }
////                            }
////                        }
////                    }
////                }, label: {
////                    Image(systemName: "return")
////                        .resizable()
////                        .scaledToFit()
////                        .foregroundStyle(.black)
////                        .frame(width: UIScreen.main.bounds.width * 0.1)
////                }).opacity(degrees == -180 ? 1 : 0)
////                Spacer()
////                AddEntryButtonView()
////                    .opacity(degrees == -180 ? 1 : 0)
////            }.padding(.horizontal, 20).offset(y: UIScreen.main.bounds.height * 0.33)
//=======
//
//import SwiftUI
//
//struct OpenJournal: View {
//    @Namespace private var openJournalNamespace
////    @State var book: any Book
//    @ObservedObject var userVM: UserViewModel
//    @ObservedObject var journal: Journal
//    @State var shelfIndex: Int
//    @State var bookIndex: Int
//    @Binding var degrees: CGFloat
//    @Binding var isHidden: Bool
//    @Binding var show: Bool
//    @State var displayDegrees: CGFloat = 0
//    @Binding var frontDegrees: CGFloat
//    @State var zIndex: Double = -1
//    @Binding var circleStart: CGFloat
//    @Binding var circleEnd: CGFloat
//    @Binding var displayPageIndex: Int
//    @State var displayIsHidden: Bool = false
//    @State var frontIsHidden: Bool = true
//    @Binding var coverZ: Double
//    @Binding var scaleFactor: CGFloat
//    @Binding var inTextEntry: Bool
//    @State var entryIndex = -1
//    @State var scaleFactor2 = 0
//    @Binding var selectedEntry: Int
//    @Binding var showNavBack: Bool
//    var body: some View {
//        ZStack {
//            JournalBackPagesView(book: journal, displayPageIndex: $displayPageIndex, degrees: $degrees)
//            JournalDisplayView(displayIsHidden: $displayIsHidden, userVM: userVM, journal: journal, shelfIndex: shelfIndex, bookIndex: bookIndex, displayPageIndex: $displayPageIndex, zIndex: $zIndex, displayDegrees: $displayDegrees, circleStart: $circleStart, circleEnd: $circleEnd, frontIsHidden: $frontIsHidden, frontDegrees: $frontDegrees, inTextEntry: $inTextEntry, selectedEntry: $selectedEntry)
//            
//            JournalFrontPagesView(book: journal, degrees: $degrees, frontIsHidden: $frontIsHidden, displayPageIndex: $displayPageIndex, frontDegrees: $frontDegrees, isHidden: $isHidden, coverZ: $coverZ)
//            VStack {
//                ForEach(0..<9, id: \.self) { i in
//                    VStack(spacing: 0) {
//                        ZStack {
//                            Circle()
//                                .trim(from: circleStart, to: circleEnd)
//                                .stroke(lineWidth: 2)
//                                .frame(width: UIScreen.main.bounds.width * 0.08)
//                                .opacity(isHidden ? 1 : 0)
//                            
//                        }.frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.04)
//                        
//                    }
//                    
//                    
//                }
//            }.offset(x: UIScreen.main.bounds.width * -0.45)
//            HStack {
//                Button(action: {
//                    circleStart = 0.5
//                    circleEnd = 1
//                    withAnimation(.linear(duration: 1).delay(0.5)) {
//                        circleStart += 0.25
//                        degrees += 90
//                        frontDegrees += 90
//                    } completion: {
//                        coverZ = 0
//                        isHidden = false
//                        withAnimation {
//                            circleStart += 0.25
//                            degrees += 90
//                            frontDegrees += 90
//                        } completion: {
//                            withAnimation(.linear(duration: 0.7)) {
//                                scaleFactor = 0.6
//                            } completion: {
//                                showNavBack.toggle()
//                                withAnimation {
//                                    show.toggle()
//                                }
//                            }
//                        }
//                    }
//                }, label: {
//                    Image(systemName: "return")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundStyle(.black)
//                        .frame(width: UIScreen.main.bounds.width * 0.1)
//                }).opacity(degrees == -180 ? 1 : 0)
//                Spacer()
//                AddEntryButtonView(journal: journal, inTextEntry: $inTextEntry, userVM: userVM, displayPage: $displayPageIndex, selectedEntry: $selectedEntry)
//                    .opacity(degrees == -180 ? 1 : 0)
//            }.padding(.horizontal, 20).offset(y: UIScreen.main.bounds.height * 0.33)
//        }
// 
//    }
//}
//>>>>>>> main
////
////        }
//// 
////    }
////}
//<<<<<<< HEAD
//////
//////#Preview {
//////    OpenJournal(book: shelf.books[number], degrees: $degrees)
//////}
////
//////struct JournalBackPagesView: View {
//////    @ObservedObject var book: Journal
//////    @Binding var displayPageIndex: Int
//////    @Binding var degrees: CGFloat
//////    var body: some View {
//////        RoundedRectangle(cornerRadius: 10)
//////            .fill(book.template.coverColor)
//////            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
//////            .overlay(
//////                Image("\(book.template.texture)") // Load texture image from assets
//////                    .resizable()
//////                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
//////                    .clipShape(RoundedRectangle(cornerRadius: 10))
//////                    .scaledToFill()
//////                    .opacity(0.4) // Adjust for realism
//////            )
//////            .shadow(color: .black.opacity(0.3), radius: 5, x: 5, y: 5) // Gives depth
//////            .zIndex(-4)
//////        //Back Page
//////        ZStack {
//////            RoundedRectangle(cornerRadius: 10)
//////                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//////                .foregroundStyle(book.template.pageColor)
//////                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
//////                .zIndex(-2)
//////            VStack {
//////                if displayPageIndex + 1 < book.pages.count && displayPageIndex - 1 > -1{
//////                    ForEach(book.pages[displayPageIndex + 1].entries.indices, id: \.self) { index in
//////                        JournalTextWidgetView(entry: $book.pages[displayPageIndex + 1].entries[index])
//////                            .padding(.top, 10)
//////                    }
//////                }
//////                Spacer()
//////                HStack {
//////                    Spacer()
//////                    Text(displayPageIndex + 1 < book.pages.count && displayPageIndex > -1 ? "\(book.pages[displayPageIndex + 1].number)" : "no more pages")
//////                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
//////                        .opacity(degrees == 0 ? 0 : 1)
//////                }.frame(width: UIScreen.main.bounds.width * 0.87)
//////            }
//////        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//////    }
//////}
//////
//////struct JournalFrontPagesView: View {
//////    @ObservedObject var book: Journal
//////    @Binding var degrees: CGFloat
//////    @Binding var frontIsHidden: Bool
//////    @Binding var displayPageIndex: Int
//////    @Binding var frontDegrees: CGFloat
//////    @Binding var isHidden: Bool
//////    @Binding var coverZ: Double
//////    var body: some View {
//////        //Fake Front Page
//////        RoundedRectangle(cornerRadius: 10)
//////            .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//////            .zIndex(0)
//////            .foregroundStyle(book.template.pageColor)
//////            .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
//////            .rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
//////        //Front Page
//////        ZStack {
//////            RoundedRectangle(cornerRadius: 10)
//////                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//////                .zIndex(0)
//////                .foregroundStyle(book.template.pageColor)
//////                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
//////            VStack {
//////                if displayPageIndex - 1 < book.pages.count && displayPageIndex - 1 > -1 {
//////                    ForEach(book.pages[displayPageIndex - 1].entries.indices, id: \.self) { index in
//////                        JournalTextWidgetView(entry: $book.pages[displayPageIndex - 1].entries[index])
//////                            .padding(.top, 10)
//////                            .opacity(frontIsHidden ? 0 : 1)
//////                    }
//////                }
//////                Spacer()
//////                HStack {
//////                    Spacer()
//////                    Text(displayPageIndex - 1 < book.pages.count && displayPageIndex > -1 ? "\(book.pages[displayPageIndex - 1].number)" : "no more pages")
//////                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
//////                }
//////            }
//////            //                    .opacity(frontIsHidden ? 0 : 1)
//////        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//////            .rotation3DEffect(.degrees(frontDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
//////        ZStack {
//////            RoundedRectangle(cornerRadius: 10)
//////                .fill(book.template.coverColor)
//////                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
//////                .overlay(
//////                    Image("\(book.template.texture)") // Load texture image from assets
//////                        .resizable()
//////                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
//////                        .clipShape(RoundedRectangle(cornerRadius: 10))
//////                        .scaledToFill()
//////                        .opacity(0.4) // Adjust for realism
//////                )
//////                .shadow(color: .black.opacity(degrees > -180 ? 0 : 0.3), radius: 5, x: 5, y: 5) // Gives depth
//////            
//////            // Title
//////            Text(book.name)
//////                .font(.title)
//////                .foregroundStyle(book.template.titleColor)
//////                .opacity(isHidden ? 0 : 1)
//////            Rectangle()
//////                .fill(book.template.coverColor) // Darker than cover color
//////                .brightness(-0.2)
//////                .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
//////                .offset(x: UIScreen.main.bounds.width * -0.42)
//////                .shadow(radius: 3)
//////                .opacity(isHidden ? 0 : 1)
//////                .zIndex(-3)
//////                .overlay(
//////                    Image("\(book.template.texture)") // Load texture image from assets
//////                        .resizable()
//////                        .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
//////                        .offset(x: UIScreen.main.bounds.width * -0.42)
//////                        .scaledToFill()
//////                        .opacity(isHidden ? 0 : 0.4) // Adjust for realism
//////                )
//////        }.rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
//////            .zIndex(coverZ)
//////    }
//////}
//////
//////struct JournalDisplayView: View {
//////    @Binding var displayIsHidden: Bool
//////    @ObservedObject var userVM: UserViewModel
//////    @ObservedObject var journal: Journal
//////    @State var shelfIndex: Int
//////    @State var bookIndex: Int
//////    @Binding var displayPageIndex: Int
//////    @Binding var zIndex: Double
//////    @Binding var displayDegrees: CGFloat
//////    @Binding var circleStart: CGFloat
//////    @Binding var circleEnd: CGFloat
//////    @Binding var frontIsHidden: Bool
//////    @Binding var frontDegrees: CGFloat
//////    @Binding var inTextEntry: Bool
//////    @State var scaleFactor: CGFloat = 1
//////    @Binding var selectedEntry: Int
//////    var body: some View {
//////        ZStack(alignment: .top) {
//////            RoundedRectangle(cornerRadius: 10)
//////                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//////                .zIndex(displayIsHidden ? 0 : zIndex)
//////                .foregroundStyle(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).template.pageColor)
//////                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
//////            VStack {
//////                if displayPageIndex < userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages.count && displayPageIndex > -1 {
//////                    ForEach(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages[displayPageIndex].entries.indices, id: \.self) { index in
//////                        JournalTextWidgetView(entry: $journal.pages[displayPageIndex].entries[index])
//////                            .padding(.top, 10)
//////                            .opacity(displayIsHidden ? 0 : 1)
//////                            .onTapGesture {
//////                                selectedEntry = index
//////                                inTextEntry.toggle()
//////                            }
//////                      
//////                    }
//////                }
//////                Spacer()
//////                HStack {
//////                    Spacer()
//////                    Text(displayPageIndex < userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages.count && displayPageIndex > -1 ? "\(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages[displayPageIndex].number)" : "no more pages")
//////                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
//////                }
//////            }
//////            
//////        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//////            .rotation3DEffect(.degrees(displayDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
//////            .gesture(
//////                DragGesture()
//////                    .onEnded({ value in
//////                        if value.translation.width < 0 {
//////                            circleStart = 0.5
//////                            circleEnd = 1
//////                            zIndex = -0.5
//////                            withAnimation(.linear(duration: 0.5).delay(0.5)) {
//////                                displayDegrees -= 90
//////                                circleEnd -= 0.25
//////                            } completion: {
//////                                circleStart = 0.75
//////                                circleEnd = 1
//////                                displayIsHidden = true
//////                                withAnimation(.linear(duration: 0.5).delay(0)) {
//////                                    displayDegrees -= 90
//////                                    circleStart -= 0.25
//////                                } completion: {
//////                                    displayDegrees = 0
//////                                    displayPageIndex += 1
//////                                    displayIsHidden = false
//////                                }
//////                            }
//////                        }
//////                        
//////                        if value.translation.width > 0 {
//////                            // right
//////                            circleStart = 0.5
//////                            circleEnd = 1
//////                            withAnimation(.linear(duration: 0.5).delay(0.5)) {
//////                                frontDegrees += 90
//////                                circleStart += 0.25
//////                            } completion: {
//////                                frontIsHidden = false
//////                                circleStart = 0.5
//////                                circleEnd = 0.75
//////                                withAnimation(.linear(duration: 0.5).delay(0)) {
//////                                    frontDegrees += 90
//////                                    circleEnd += 0.25
//////                                } completion: {
//////                                    displayPageIndex -= 1
//////                                    frontDegrees = -180
//////                                    frontIsHidden = true
//////                                }
//////                            }
//////                        }
//////                    })
//////            )
//////    }
//////}
//////
//////#Preview {
//////    struct Preview: View {
//////        @State var degrees: CGFloat = -180
//////        @State var frontDegrees: CGFloat = -180
//////        @State var show: Bool = true
//////        @State var cover: Double = -2
//////        @State var circleStart: CGFloat = 0.5
//////        @State var circleEnd: CGFloat = 1
//////        @State var scaleFactor: CGFloat = 0.6
//////        @State var isHidden: Bool = true
//////        @State var mainCircleStart: CGFloat = 0.5
//////        @State var inTextEntry = false
//////        @State var selectedEntry: Int = 0
//////        @State var displayPageIndex: Int = 2
//////        @State var showNavBack: Bool = false
//////        @ObservedObject var userVM: UserViewModel = UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
//////            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")]), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")]), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")]), JournalPage(number: 5, entries: [])]),
//////            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
//////            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
//////            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])])
//////        ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: []))
//////        var body: some View {
//////            OpenJournal(userVM: userVM, journal: userVM.getJournal(shelfIndex: 0, bookIndex: 0), shelfIndex: 0, bookIndex: 0, degrees: $degrees, isHidden: $isHidden, show: $show, frontDegrees: $frontDegrees, circleStart: $circleStart, circleEnd: $circleEnd, displayPageIndex: $displayPageIndex, coverZ: $cover, scaleFactor: $scaleFactor, inTextEntry: $inTextEntry, selectedEntry: $selectedEntry, showNavBack: $showNavBack)
//////        }
//////    }
//////
//////    return Preview()
//////}
//=======
//
//struct JournalBackPagesView: View {
//    @ObservedObject var book: Journal
//    @Binding var displayPageIndex: Int
//    @Binding var degrees: CGFloat
//    var body: some View {
//        RoundedRectangle(cornerRadius: 10)
//            .fill(book.template.coverColor)
//            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
//            .overlay(
//                Image("\(book.template.texture)") // Load texture image from assets
//                    .resizable()
//                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .scaledToFill()
//                    .opacity(0.4) // Adjust for realism
//            )
//            .shadow(color: .black.opacity(0.3), radius: 5, x: 5, y: 5) // Gives depth
//            .zIndex(-4)
//        //Back Page
//        ZStack {
//            RoundedRectangle(cornerRadius: 10)
//                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//                .foregroundStyle(book.template.pageColor)
//                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
//                .zIndex(-2)
//            VStack {
//                if displayPageIndex + 1 < book.pages.count && displayPageIndex + 1 > -1{
//                    ForEach(book.pages[displayPageIndex + 1].entries.indices, id: \.self) { index in
//                        JournalTextWidgetView(entry: $book.pages[displayPageIndex + 1].entries[index])
//                            .padding(.top, 10)
//                    }
//                }
//                Spacer()
//                HStack {
//                    Spacer()
//                    Text(displayPageIndex + 1 < book.pages.count && displayPageIndex + 1 > -1 ? "\(book.pages[displayPageIndex + 1].number)" : "no more pages")
//                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
//                        .opacity(degrees == 0 ? 0 : 1)
//                }.frame(width: UIScreen.main.bounds.width * 0.87)
//            }
//        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//    }
//}
//
//struct JournalFrontPagesView: View {
//    @ObservedObject var book: Journal
//    @Binding var degrees: CGFloat
//    @Binding var frontIsHidden: Bool
//    @Binding var displayPageIndex: Int
//    @Binding var frontDegrees: CGFloat
//    @Binding var isHidden: Bool
//    @Binding var coverZ: Double
//    var body: some View {
//        //Fake Front Page
//        RoundedRectangle(cornerRadius: 10)
//            .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//            .zIndex(0)
//            .foregroundStyle(book.template.pageColor)
//            .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
//            .rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
//        //Front Page
//        ZStack {
//            RoundedRectangle(cornerRadius: 10)
//                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//                .zIndex(0)
//                .foregroundStyle(book.template.pageColor)
//                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
//            VStack {
//                if displayPageIndex - 1 < book.pages.count && displayPageIndex - 1 > -1 {
//                    ForEach(book.pages[displayPageIndex - 1].entries.indices, id: \.self) { index in
//                        JournalTextWidgetView(entry: $book.pages[displayPageIndex - 1].entries[index])
//                            .padding(.top, 10)
//                            .opacity(frontIsHidden ? 0 : 1)
//                    }
//                }
//                Spacer()
//                HStack {
//                    Spacer()
//                    Text(displayPageIndex - 1 < book.pages.count && displayPageIndex - 1 > -1 ? "\(book.pages[displayPageIndex - 1].number)" : "no more pages")
//                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
//                }
//            }
//            //                    .opacity(frontIsHidden ? 0 : 1)
//        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//            .rotation3DEffect(.degrees(frontDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
//        ZStack {
//            RoundedRectangle(cornerRadius: 10)
//                .fill(book.template.coverColor)
//                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
//                .overlay(
//                    Image("\(book.template.texture)") // Load texture image from assets
//                        .resizable()
//                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .scaledToFill()
//                        .opacity(0.4) // Adjust for realism
//                )
//                .shadow(color: .black.opacity(degrees > -180 ? 0 : 0.3), radius: 5, x: 5, y: 5) // Gives depth
//            
//            // Title
//            Text(book.name)
//                .font(.title)
//                .foregroundStyle(book.template.titleColor)
//                .opacity(isHidden ? 0 : 1)
//            Rectangle()
//                .fill(book.template.coverColor) // Darker than cover color
//                .brightness(-0.2)
//                .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
//                .offset(x: UIScreen.main.bounds.width * -0.42)
//                .shadow(radius: 3)
//                .opacity(isHidden ? 0 : 1)
//                .zIndex(-3)
//                .overlay(
//                    Image("\(book.template.texture)") // Load texture image from assets
//                        .resizable()
//                        .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
//                        .offset(x: UIScreen.main.bounds.width * -0.42)
//                        .scaledToFill()
//                        .opacity(isHidden ? 0 : 0.4) // Adjust for realism
//                )
//        }.rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
//            .zIndex(coverZ)
//    }
//}
//
//struct JournalDisplayView: View {
//    @Binding var displayIsHidden: Bool
//    @ObservedObject var userVM: UserViewModel
//    @ObservedObject var journal: Journal
//    @State var shelfIndex: Int
//    @State var bookIndex: Int
//    @Binding var displayPageIndex: Int
//    @Binding var zIndex: Double
//    @Binding var displayDegrees: CGFloat
//    @Binding var circleStart: CGFloat
//    @Binding var circleEnd: CGFloat
//    @Binding var frontIsHidden: Bool
//    @Binding var frontDegrees: CGFloat
//    @Binding var inTextEntry: Bool
//    @State var scaleFactor: CGFloat = 1
//    @Binding var selectedEntry: Int
//    var body: some View {
//        ZStack(alignment: .top) {
//            RoundedRectangle(cornerRadius: 10)
//                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//                .zIndex(displayIsHidden ? 0 : zIndex)
//                .foregroundStyle(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).template.pageColor)
//                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
//            VStack {
//                if displayPageIndex < journal.pages.count && displayPageIndex > -1 {
//                    ForEach(journal.pages[displayPageIndex].entries.indices, id: \.self) { index in
//                        JournalTextWidgetView(entry: $journal.pages[displayPageIndex].entries[index])
//                            .padding(.top, 10)
//                            .opacity(displayIsHidden ? 0 : 1)
//                            .onTapGesture {
//                                selectedEntry = index
//                                inTextEntry.toggle()
//                            }
//                      
//                    }
//                }
//                Spacer()
//                HStack {
//                    Spacer()
//                    Text(displayPageIndex < userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages.count && displayPageIndex > -1 ? "\(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages[displayPageIndex].number)" : "no more pages")
//                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
//                }
//            }
//            
//        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
//            .rotation3DEffect(.degrees(displayDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
//            .gesture(
//                DragGesture()
//                    .onEnded({ value in
//                        if value.translation.width < 0 {
//                            circleStart = 0.5
//                            circleEnd = 1
//                            zIndex = -0.5
//                            withAnimation(.linear(duration: 0.3).delay(0.5)) {
//                                displayDegrees -= 90
//                                circleEnd -= 0.25
//                            } completion: {
//                                circleStart = 0.75
//                                circleEnd = 1
//                                displayIsHidden = true
//                                withAnimation(.linear(duration: 0.3).delay(0)) {
//                                    displayDegrees -= 90
//                                    circleStart -= 0.25
//                                } completion: {
//                                    displayDegrees = 0
//                                    displayPageIndex += 1
//                                    displayIsHidden = false
//                                }
//                            }
//                        }
//                        
//                        if value.translation.width > 0 {
//                            // right
//                            circleStart = 0.5
//                            circleEnd = 1
//                            withAnimation(.linear(duration: 0.3).delay(0.5)) {
//                                frontDegrees += 90
//                                circleStart += 0.25
//                            } completion: {
//                                frontIsHidden = false
//                                circleStart = 0.5
//                                circleEnd = 0.75
//                                withAnimation(.linear(duration: 0.3).delay(0)) {
//                                    frontDegrees += 90
//                                    circleEnd += 0.25
//                                } completion: {
//                                    displayPageIndex -= 1
//                                    frontDegrees = -180
//                                    frontIsHidden = true
//                                }
//                            }
//                        }
//                    })
//            )
//    }
//}
//
//#Preview {
//    struct Preview: View {
//        @State var degrees: CGFloat = -180
//        @State var frontDegrees: CGFloat = -180
//        @State var show: Bool = true
//        @State var cover: Double = -2
//        @State var circleStart: CGFloat = 0.5
//        @State var circleEnd: CGFloat = 1
//        @State var scaleFactor: CGFloat = 0.6
//        @State var isHidden: Bool = true
//        @State var mainCircleStart: CGFloat = 0.5
//        @State var inTextEntry = false
//        @State var selectedEntry: Int = 0
//        @State var displayPageIndex: Int = 2
//        @State var showNavBack: Bool = false
//        @ObservedObject var userVM: UserViewModel = UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
//            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")]), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")]), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")]), JournalPage(number: 5, entries: [])], currentPage: 3),
//            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])], currentPage: 0),
//            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])], currentPage: 0),
//            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])], currentPage: 0)
//        ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: []))
//        var body: some View {
//            OpenJournal(userVM: userVM, journal: userVM.getJournal(shelfIndex: 0, bookIndex: 0), shelfIndex: 0, bookIndex: 0, degrees: $degrees, isHidden: $isHidden, show: $show, frontDegrees: $frontDegrees, circleStart: $circleStart, circleEnd: $circleEnd, displayPageIndex: $displayPageIndex, coverZ: $cover, scaleFactor: $scaleFactor, inTextEntry: $inTextEntry, selectedEntry: $selectedEntry, showNavBack: $showNavBack)
//        }
//    }
//
//    return Preview()
//}
//>>>>>>> main
