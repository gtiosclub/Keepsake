//
//  Open Journal.swift
//  Keepsake
//
//  Created by Alec Hance on 2/11/25.
//

import SwiftUI

struct OpenJournal: View {
    @Namespace private var openJournalNamespace
//    @State var book: any Book
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var journal: Journal
    @State var shelfIndex: Int
    @State var bookIndex: Int
    @Binding var degrees: CGFloat
    @Binding var isHidden: Bool
    @Binding var show: Bool
    @State var displayDegrees: CGFloat = 0
    @Binding var frontDegrees: CGFloat
    @State var zIndex: Double = -1
    @Binding var circleStart: CGFloat
    @Binding var circleEnd: CGFloat
    @Binding var displayPageIndex: Int
    @State var displayIsHidden: Bool = false
    @State var frontIsHidden: Bool = true
    @Binding var coverZ: Double
    @Binding var scaleFactor: CGFloat
    @Binding var inEntry: EntryType
    @State var entryIndex = -1
    @State var scaleFactor2 = 0
    @Binding var selectedEntry: Int
    @State private var showSearch = false
    @Binding var hideToolBar: Bool
    @Binding var dailyPrompt: String?
    @State var showPagesSheet: Bool = false
    var body: some View {
        // This ZStack will define the base frame
        ZStack {
            // Main content that defines the frame
            ZStack {
                JournalBackPagesView(book: journal, displayPageIndex: $displayPageIndex, degrees: $degrees, userVM: userVM, scaleFactor: $scaleFactor, fbVM: fbVM, frontDegrees: $frontDegrees)
                JournalDisplayView(displayIsHidden: $displayIsHidden, userVM: userVM, journal: journal, shelfIndex: shelfIndex, bookIndex: bookIndex, displayPageIndex: $displayPageIndex, zIndex: $zIndex, displayDegrees: $displayDegrees, circleStart: $circleStart, circleEnd: $circleEnd, frontIsHidden: $frontIsHidden, frontDegrees: $frontDegrees, inEntry: $inEntry, selectedEntry: $selectedEntry, fbVM: fbVM)
                JournalFrontPagesView(book: journal, degrees: $degrees, frontIsHidden: $frontIsHidden, displayPageIndex: $displayPageIndex, frontDegrees: $frontDegrees, isHidden: $isHidden, coverZ: $coverZ, userVM: userVM, fbVM: fbVM)
                
                VStack {
                    ForEach(0..<9, id: \.self) { _ in
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .trim(from: circleStart, to: circleEnd)
                                    .stroke(lineWidth: 2)
                                    .frame(width: UIScreen.main.bounds.width * 0.08)
                                    .opacity(isHidden ? 1 : 0)
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.08, height: UIScreen.main.bounds.height * 0.04)
                        }
                    }
                }
                .offset(x: UIScreen.main.bounds.width * -0.45)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
            .background(Color.clear)
            // Floating header (positioned absolutely)
            VStack {
                // Your header content...
                HStack(alignment: .top, spacing: 15) {
                    VStack(alignment: .leading) {
                        Text(journal.name).font(.system(size: 40))
                        Text(journal.createdDate).font(.system(size: 20))
                        Text("created by...").font(.system(size: 15))
                    }
                    Spacer()
                    Button(action: { withAnimation(.spring()) { showSearch = true } }) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(.top, 8)
                            .foregroundColor(.black)
                    }
                    Button {
                        showPagesSheet.toggle()
                    } label: {
                        Image(systemName: "book.pages")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(.top, 8)
                            .foregroundColor(.black)
                    }
                    Button {} label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(.top, 8)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 30)
                .opacity(degrees == -180 ? 1 : 0)
                
                Spacer()
                
                // Floating footer (positioned absolutely)
                HStack {
                    JournalReturnButton(circleStart: $circleStart, circleEnd: $circleEnd, frontDegrees: $frontDegrees, degrees: $degrees, isHidden: $isHidden, coverZ: $coverZ, scaleFactor: $scaleFactor, show: $show, hideToolBar: $hideToolBar)
                    Spacer()
                    AddEntryButtonView(journal: journal, inEntry: $inEntry, userVM: userVM, fbVM: fbVM, aiVM: aiVM, displayPage: $displayPageIndex, selectedEntry: $selectedEntry, dailyPrompt: $dailyPrompt)
                }
                .padding(.horizontal, 30)
                .opacity(degrees == -180 ? 1 : 0)
            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.56 + 155)
                .offset(y: UIScreen.main.bounds.height * -0.03)
            
            if showSearch {
                SearchOverlayView(isPresented: $showSearch, firebaseVM: FirebaseViewModel.vm, journalID: journal.id.uuidString)
                    .transition(.opacity.combined(with: .scale(scale: 1.1)))
                    .zIndex(2)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
        .fixedSize()
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showPagesSheet) {
            JournalPagesView(userVM: userVM, fbVM: fbVM, journal: journal, isPresented: $showPagesSheet)
        }
    }
}


struct JournalBackPagesView: View {
    @ObservedObject var book: Journal
    @Binding var displayPageIndex: Int
    @Binding var degrees: CGFloat
    @State var inEntry: EntryType = .openJournal
    @State var selectedEntry: Int = 0
    @ObservedObject var userVM: UserViewModel
    @State var showDeleteButton: Int = -1
    @Binding var scaleFactor: CGFloat
    @ObservedObject var fbVM: FirebaseViewModel
    @Binding var frontDegrees: CGFloat
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
            .shadow(color: .black.opacity(scaleFactor == 0.6 ? 0.0 : 0.3), radius: 5, x: 5, y: 5) // Gives depth
            .zIndex(-4)
        //Back Page
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
                .foregroundStyle(book.template.pageColor)
                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
                .zIndex(-2)
            VStack {
                if displayPageIndex + 1 < book.pages.count && displayPageIndex + 1 > -1{
                    WidgetView(width: UIScreen.main.bounds.width * 0.38, height: UIScreen.main.bounds.height * 0.12, padding: UIScreen.main.bounds.width * 0.02, pageNum: displayPageIndex + 1, page: book.pages[displayPageIndex + 1], isDisplay: false, inEntry: $inEntry, selectedEntry: $selectedEntry, userVM: userVM, showDeleteButton: $showDeleteButton, journal: book, fbVM: fbVM, frontDegrees: $frontDegrees)

                        .frame(width: UIScreen.main.bounds.width * 0.87)
                        .padding(.top, 10)
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(displayPageIndex + 1 < book.pages.count && displayPageIndex + 1 > -1 ? "\(book.pages[displayPageIndex + 1].number)" : "no more pages")
                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
                        .opacity(degrees == 0 ? 0 : 1)
                }.frame(width: UIScreen.main.bounds.width * 0.87)
            }
        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
    }
}

struct JournalFrontPagesView: View {
    @ObservedObject var book: Journal
    @Binding var degrees: CGFloat
    @Binding var frontIsHidden: Bool
    @Binding var displayPageIndex: Int
    @Binding var frontDegrees: CGFloat
    @Binding var isHidden: Bool
    @Binding var coverZ: Double
    @State var inEntry: EntryType = .openJournal
    @State var selectedEntry: Int = 0
    @ObservedObject var userVM: UserViewModel
    @State var showDeleteButton: Int = -1
    @ObservedObject var fbVM: FirebaseViewModel
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
                    WidgetView(width: UIScreen.main.bounds.width * 0.38, height: UIScreen.main.bounds.height * 0.12, padding: UIScreen.main.bounds.width * 0.02, pageNum: displayPageIndex - 1, page: book.pages[displayPageIndex - 1], isDisplay: false, inEntry: $inEntry, selectedEntry: $selectedEntry, userVM: userVM, showDeleteButton: $showDeleteButton, journal: book, fbVM: fbVM, frontDegrees: $frontDegrees)
                        .frame(width: UIScreen.main.bounds.width * 0.87)
                        .padding(.top, 10)
                        .opacity(frontIsHidden ? 0 : 1)
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(displayPageIndex - 1 < book.pages.count && displayPageIndex - 1 > -1 ? "\(book.pages[displayPageIndex - 1].number)" : "no more pages")
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
                //.shadow(color: .black.opacity(degrees > -180 ? 0 : 0.3), radius: 5, x: 5, y: 5) // Gives depth
            
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
                //.shadow(radius: 3)
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

struct JournalDisplayView: View {
    @Binding var displayIsHidden: Bool
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var journal: Journal
    @State var shelfIndex: Int
    @State var bookIndex: Int
    @Binding var displayPageIndex: Int
    @Binding var zIndex: Double
    @Binding var displayDegrees: CGFloat
    @Binding var circleStart: CGFloat
    @Binding var circleEnd: CGFloat
    @Binding var frontIsHidden: Bool
    @Binding var frontDegrees: CGFloat
    @Binding var inEntry: EntryType
    @State var scaleFactor: CGFloat = 1
    @Binding var selectedEntry: Int
    @State var showDeleteButton: Int = -1
    @ObservedObject var fbVM: FirebaseViewModel
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
                .zIndex(displayIsHidden ? 0 : zIndex)
                .foregroundStyle(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).template.pageColor)
                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
            VStack {
                if displayPageIndex < journal.pages.count && displayPageIndex > -1 {
                    WidgetView(width: UIScreen.main.bounds.width * 0.38, height: UIScreen.main.bounds.height * 0.12, padding: UIScreen.main.bounds.width * 0.02, pageNum: displayPageIndex, page: journal.pages[displayPageIndex], isDisplay: true, inEntry: $inEntry, selectedEntry: $selectedEntry, userVM: userVM, showDeleteButton: $showDeleteButton, journal: journal, fbVM: fbVM, frontDegrees: $frontDegrees)
                        .frame(width: UIScreen.main.bounds.width * 0.87)
                        .padding(.top, 10)
                        .opacity(displayIsHidden ? 0 : 1)
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(displayPageIndex < userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages.count && displayPageIndex > -1 ? "\(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages[displayPageIndex].number)" : "no more pages")
                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
                }
            }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
            
        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
            .rotation3DEffect(.degrees(displayDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
            .gesture(
                DragGesture()
                    .onEnded({ value in
                        if value.translation.width < 0 && displayPageIndex
                            != journal.pages.count - 1 {
                            showDeleteButton = -1
                            circleStart = 0.5
                            circleEnd = 1
                            zIndex = -0.5
                            withAnimation(.linear(duration: 0.3).delay(0.5)) {
                                displayDegrees -= 90
                                circleEnd -= 0.25
                            } completion: {
                                circleStart = 0.75
                                circleEnd = 1
                                displayIsHidden = true
                                withAnimation(.linear(duration: 0.3).delay(0)) {
                                    displayDegrees -= 90
                                    circleStart -= 0.25
                                } completion: {
                                    displayDegrees = 0
                                    displayPageIndex += 1
                                    displayIsHidden = false
                                }
                            }
                        }
                        
                        if value.translation.width > 0 && displayPageIndex
                            != 0 {
                            showDeleteButton = -1
                            // right
                            circleStart = 0.5
                            circleEnd = 1
                            withAnimation(.linear(duration: 0.3).delay(0.5)) {
                                frontDegrees += 90
                                circleStart += 0.25
                            } completion: {
                                frontIsHidden = false
                                circleStart = 0.5
                                circleEnd = 0.75
                                withAnimation(.linear(duration: 0.3).delay(0)) {
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
    }
}

struct JournalReturnButton: View {
    @Binding var circleStart: CGFloat
    @Binding var circleEnd: CGFloat
    @Binding var frontDegrees:CGFloat
    @Binding var degrees: CGFloat
    @Binding var isHidden: Bool
    @Binding var coverZ: Double
    @Binding var scaleFactor: CGFloat
    @Binding var show: Bool
    @Binding var hideToolBar: Bool
    var body: some View {
        VStack {
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
                            } completion: {
                                hideToolBar.toggle()
                            }
                        }
                    }
                }
            }, label: {
                Image(systemName: "return")
                    .resizable()
                    .foregroundStyle(.black)
                    .frame(width: UIScreen.main.bounds.width * 0.07, height: UIScreen.main.bounds.width * 0.07)
            }).frame(width: UIScreen.main.bounds.width * 0.1)
            
        }
    }
}


#Preview {
    struct Preview: View {
        @State var degrees: CGFloat = -180
        @State var frontDegrees: CGFloat = -180
        @State var show: Bool = true
        @State var cover: Double = -2
        @State var circleStart: CGFloat = 0.5
        @State var circleEnd: CGFloat = 1
        @State var scaleFactor: CGFloat = 0.6
        @State var isHidden: Bool = true
        @State var mainCircleStart: CGFloat = 0.5
        @State var inEntry: EntryType = .openJournal
        @State var selectedEntry: Int = 0
        @State var displayPageIndex: Int = 0
        @State var showNavBack: Bool = false
        @State var hideToolBar: Bool = true
        @ObservedObject var userVM: UserViewModel = UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: []))
        var body: some View {
            OpenJournal(userVM: userVM, fbVM: FirebaseViewModel(), aiVM: AIViewModel(), journal: userVM.getJournal(shelfIndex: 0, bookIndex: 0), shelfIndex: 0, bookIndex: 0, degrees: $degrees, isHidden: $isHidden, show: $show, frontDegrees: $frontDegrees, circleStart: $circleStart, circleEnd: $circleEnd, displayPageIndex: $displayPageIndex, coverZ: $cover, scaleFactor: $scaleFactor, inEntry: $inEntry, selectedEntry: $selectedEntry, hideToolBar: $hideToolBar, dailyPrompt: .constant("Test"))
        }
    }

    return Preview()
}
