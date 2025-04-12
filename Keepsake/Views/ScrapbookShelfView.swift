//
//  JournalView.swift
//  Keepsake
//
//  Created by Chaerin Lee on 2/5/25.
//
import SwiftUI

struct ScrapbookShelfView: View {
    @Namespace private var scrapbookShelfNamespace
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var shelf: ScrapbookShelf
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    var shelfIndex: Int
    @Binding var showScrapbookForm: Bool
    @Binding var selectedOption: ViewOption
    @State var showDeleteButton: Bool = false
    @State var deleteScrapbookID: String = ""
    @State var hideToolBar: Bool = false
    @State var showOnlyCover: Bool = true
    @State var scaleEffect: CGFloat = 0.6
    @State var currentScrollIndex: Int = 0
    var body: some View {
        ZStack {
            scrapbookShelfParent
                .ignoresSafeArea(.container, edges: .top)
        }
        .background(
            Group {
                VStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 700)
                        .shadow(color: Color.black.opacity(0.3), radius: 50, x: 0, y: 20)
                        .blur(radius: 1)
                        .offset(y: 450)
                        .allowsHitTesting(false)
                        .zIndex(-1)
                        .transition(.opacity)
                }.frame(maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea(.container, edges: .top)
            }
        )
    }
    
    private var scrapbookShelfParent: some View {
        VStack(alignment: .leading, spacing: 10) {
            scrapbookTopVStack
                .transition(
                    .opacity
                        .animation(.easeIn(duration: 0.5)) // Fast appear
                )
                .padding(.top, 70)
            scrapbookTextView
                .transition(
                    .opacity
                        .animation(.easeIn(duration: 0.5)) // Fast appear
                )
                .padding(.bottom, 10)
            scrapbookButtonNavigationView
                .transition(.opacity.animation(.easeIn(duration: 0.5)))
                .padding(.bottom, 50)
            if shelf.scrapbooks.count == 0 {
                scrapbookDefaultScrollView
                    .padding(.top, UIScreen.main.bounds.height * -0.05)
                    
            } else {
                scrapbookScrollView
                    .transition(
                        .opacity
                            .animation(.easeIn(duration: 0.01)) // Fast appear
                    ).padding(.top, UIScreen.main.bounds.height * -0.05)
            }
        }
        .toolbar(hideToolBar ? .hidden : .visible, for: .tabBar)
        .onTapGesture(perform: {
            if showDeleteButton {
                showDeleteButton.toggle()
            }
        })
        .frame(maxHeight: .infinity, alignment: .top)
        
    }
    
    private var scrapbookTextView: some View {
        Text("What is on your mind today?")
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.leading)
            .lineLimit(nil) // Allow multiple lines
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 30)
    }
    
    private var scrapbookTopVStack: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Welcome back, \(userVM.user.name)")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                    .padding(.leading, 30)
                
                Spacer()
                
                Button(action: { print("Button tapped - showJournalForm before: \(showScrapbookForm)")
                    showScrapbookForm = true
                    print("Button tapped - showJournalForm after: \(showScrapbookForm)") }) {
                     Image(systemName: "plus")
                         .font(.system(size: 28))
                         .foregroundColor(Color(hex: "#7FD2E7"))
                         
                }.padding(.top, 20)
                    .padding(.trailing, 30)
            }
        }
    }
    
    private var scrapbookButtonNavigationView: some View {
        HStack(spacing: 26) { // Reduced spacing
            Spacer()
            
            Button(action: {
                print("Journal clicked")
                userVM.setLastUsed(isJournal: true)
                Task {
                    await fbVM.updateUserLastUsedJShelf(user: userVM.user)
                }
                selectedOption = .journal_shelf
            }) {
                Text("Journal")
                    .font(.system(size: 14, weight: .semibold)) // Smaller font
                    .foregroundColor(.gray.opacity(1))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12) // Smaller corner radius
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                // Add selectedOption = .arScrapbook after adding enum in HomeView
                print("AR Scrapbook clicked")
            }) {
                Text("AR Scrapbook")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#7FD2E7"))
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                selectedOption = .library
                print("Library clicked")
            }) {
                Text("Library")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(1))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.vertical, 1)
        .frame(maxWidth: .infinity)
        .zIndex(1)
    }
    
    private var scrapbookScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 45) {
                    ForEach(Array(userVM.user.scrapbookShelves[shelfIndex].scrapbooks.enumerated()), id: \.element.id) { index, scrapbook in
                        GeometryReader { geometry in
                            let verticalOffset = calculateVerticalOffset(proxy: geometry)
                            VStack(spacing: 35) {
                                ZStack {
                                    NavigationLink {
                                        CreateScrapbookView(fbVM: fbVM, userVM: userVM, scrapbook: scrapbook)
                                    } label: {
                                        JournalCover(template: scrapbook.template, degrees: 0, title: scrapbook.name, showOnlyCover: $showOnlyCover, offset: true)
                                            .scaleEffect(scaleEffect)
                                            .frame(width: UIScreen.main.bounds.width * 0.92 * scaleEffect, height: UIScreen.main.bounds.height * 0.56 * scaleEffect)
                                            .transition(.identity)
                                            .matchedGeometryEffect(id: "journal_\(scrapbook.id)", in: scrapbookShelfNamespace, properties: .position, anchor: .center)
                                            .onTapGesture(count: 2) { // Detect double tap
                                                withAnimation(.spring()) {
                                                    showDeleteButton.toggle()
                                                    deleteScrapbookID = scrapbook.id.uuidString
                                                }
                                            }
                                    }
                                }
                                if showDeleteButton && deleteScrapbookID == scrapbook.id.uuidString {
                                    Button {
                                        userVM.removeScrapbookFromShelf(shelfIndex: shelfIndex, scrapbookID: scrapbook.id)
                                        Task {
                                            await fbVM.deleteScrapbook(scrapbookID: scrapbook.id.uuidString, scrapbookShelfID: userVM.getScrapbookShelves()[shelfIndex].id)
                                        }
                                        showDeleteButton.toggle()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.red)
                                            .background(Circle().fill(Color.white))
                                            .padding(8)
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                    .zIndex(1)
                                }
                                VStack(spacing: 10) {
                                    //Journal name, date, created by you
                                    Text(scrapbook.name)
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    
                                    Text(scrapbook.createdDate)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 15, height: 15)
                                        
                                        Text("created by You")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.top, 20)
                                .frame(width: 200)
                            }
                            .frame(width: 240, height: 700)
                            .offset(y: verticalOffset)
                            .id(index)
                        }
                        .frame(width: 240, height: 600)
                    }
                }
                .padding(.horizontal, 70)
            }
            .coordinateSpace(name: "scrollView")
            .frame(height: 500, alignment: .bottom)
            .padding(.top, 30)
            .onAppear {
                currentScrollIndex = 0
                proxy.scrollTo(currentScrollIndex, anchor: .center)
            }
            .highPriorityGesture(
                DragGesture(coordinateSpace: .named("scrollView"))
                    .onEnded { value in
                        let threshold: CGFloat = 100
                        if abs(value.translation.width) > threshold {
                            let nextJournal = value.translation.width > 0 ? -1 : 1
                            let newIndex = min(max(currentScrollIndex + nextJournal,0), shelf.scrapbooks.count-1)
                            
                            withAnimation {
                                currentScrollIndex = newIndex
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
            )
        }

    }
    
    private var scrapbookDefaultScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 45) {
                    ForEach(0..<1, id: \.self) { index in
                        GeometryReader { geometry in
                            let verticalOffset = calculateVerticalOffset(proxy: geometry)
                            VStack(spacing: 35) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.black)
                                        .fill(.white)
                                        .frame(width: UIScreen.main.bounds.width * 0.92 * scaleEffect,
                                               height: UIScreen.main.bounds.height * 0.56 * scaleEffect)
                                        .offset(y: UIScreen.main.bounds.height * 0.05 * scaleEffect)
                                    Image(systemName: "plus.app")
                                        .font(.system(size: 30))
                                        .offset(y: UIScreen.main.bounds.height * 0.05 * scaleEffect)
                                }
                                .onTapGesture {
                                }
                                VStack(spacing: 10) {
                                    Text("Create New")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    Text("\(todaysdate())")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .opacity(0)
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 15, height: 15)
                                        Text("created by You")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }.opacity(0)
                                }
                                .padding(.top, 20)
                                .frame(width: 200)
                            }
                            .frame(width: 240, height: 700)
                            .offset(y: verticalOffset)
                            .id(index) // Add this to identify each journal
                        }
                        .frame(width: 240, height: 600)
                    }
                }
                .padding(.horizontal, 70)
            }
            .coordinateSpace(name: "scrollView")
            .frame(height: 500, alignment: .bottom)
            .padding(.top, 30)
            .onAppear {
                currentScrollIndex = 0
                proxy.scrollTo(currentScrollIndex, anchor: .center)
            }
            .highPriorityGesture(
                DragGesture(coordinateSpace: .named("scrollView"))
                    .onEnded { value in
                        let threshold: CGFloat = 100
                        if abs(value.translation.width) > threshold {
                            let nextJournal = value.translation.width > 0 ? -1 : 1
                            let newIndex = currentScrollIndex + nextJournal
                            
                            withAnimation {
                                currentScrollIndex = newIndex
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
            )
        }
    }

    
    func createJournal(from template: Template, shelfIndex: Int, shelfID: UUID) async {
        let newJournal = Journal(
            name: template.name,
            id: UUID(),
            createdDate: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            category: "General",
            isSaved: false,
            isShared: false,
            template: template,
            pages: template.journalPages ?? [JournalPage(number: 1)],
            currentPage: 0
        )
        //        userVM.addJournalToShelf(journal: newJournal, shelfIndex: shelfIndex)
        userVM.addJournalToShelfAndAddEntries(journal: newJournal, shelfIndex: shelfIndex)
        _ = await fbVM.addJournal(journal: newJournal, journalShelfID: shelfID)
    }
    
   
    
    
    private func calculateVerticalOffset(proxy: GeometryProxy) -> CGFloat {
        let midX = proxy.frame(in: .global).midX
        let screenMidX = UIScreen.main.bounds.midX
        let distance = abs(midX - screenMidX)
        let maxDistance: CGFloat = 200
        let centeredness = 1 - (distance / maxDistance)
        return -50 * centeredness
    }
}

#Preview {
    struct Preview: View {
        @State var selectedOption: ViewOption = .library
        @State var showScrapbookForm: Bool = false
        var body: some View {
            ScrapbookShelfView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [    JournalPage.dailyReflectionTemplate(pageNumber: 1), JournalPage.tripTemplate(pageNumber: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ]), JournalShelf(name: "Shelf 2", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ])], scrapbookShelves: [])), shelf: ScrapbookShelf(name: "Scrapshelf", scrapbooks: [Scrapbook(name: "Scrapbook1", id: UUID(), createdDate: "5/6/2026", category: "", isSaved: true, isShared: false, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [ScrapbookPage(number: 1, entries: [ScrapbookEntry(id: UUID(), type: "text", position: [0, 0, -2], scale: 1.0, rotation: [0.0, 0.0, 0.0, 0.0], text: "Hello", imageURL: nil)], entryCount: 2)], currentPage: 0)]), aiVM: AIViewModel(), fbVM: FirebaseViewModel(), shelfIndex: 0, showScrapbookForm: $showScrapbookForm, selectedOption: $selectedOption)
        }
    }

    return Preview()
}
