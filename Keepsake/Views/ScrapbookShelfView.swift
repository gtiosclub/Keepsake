//
//  JournalView.swift
//  Keepsake
//
//  Created by Chaerin Lee on 2/5/25.
//
import SwiftUI

struct ScrapbookShelfView: View {
    @Namespace private var shelfNamespace
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var shelf: ScrapbookShelf
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    var shelfIndex: Int
    @State private var showJournalForm = false
    @Binding var selectedOption: ViewOption
    @State var showDeleteButton: Bool = false
    @State var deleteJournalID: String = ""
    @State var hideToolBar: Bool = false
    @State var showOnlyCover: Bool = true
    @State var scaleEffect: CGFloat = 0.6
    var body: some View {
        ZStack {
            shelfParent
        }
    }
    
    private var shelfParent: some View {
        VStack(alignment: .leading, spacing: 10) {
            topVStack
                .transition(
                    .opacity
                        .animation(.easeIn(duration: 0.5)) // Fast appear
                )
            textView
                .transition(
                    .opacity
                        .animation(.easeIn(duration: 0.5)) // Fast appear
                )
                .padding(.bottom, 30)
            buttonNavigationView
                .transition(.opacity.animation(.easeIn(duration: 0.5)))
                .padding(.bottom, 10)
            scrollView
                .transition(
                    .opacity
                        .animation(.easeIn(duration: 0.01)) // Fast appear
                ).padding(.top, UIScreen.main.bounds.height * -0.05)
        }
        .toolbar(hideToolBar ? .hidden : .visible, for: .tabBar)
        .onTapGesture(perform: {
            if showDeleteButton {
                showDeleteButton.toggle()
            }
        })
        //            .onAppear() {
        //                print(userVM.user.journalShelves)
        //            }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private var textView: some View {
        Text("What is on your mind today?")
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.leading)
            .lineLimit(nil) // Allow multiple lines
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 30)
    }
    
    private var topVStack: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Welcome back, \(userVM.user.name)")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                    .padding(.leading, 30)
                
                Spacer()
                
                Menu {
                    Button(action: {
                        showJournalForm = true
                        print("clicked")
                    }) {
                        Text("New Journal")
                    }
                    
                    Button(action: {
                        showJournalForm = true
                    }) {
                        Text("New AR Scrapbook")
                    }
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                .padding(.trailing, 30)
            }
        }
    }
    
    private var buttonNavigationView: some View {
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
                    .background(Color.blue.opacity(0.7))
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
    
    private var scrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 45) {
                ForEach(userVM.user.scrapbookShelves[shelfIndex].scrapbooks) { scrapbook in
                    GeometryReader { geometry in
                        let verticalOffset = calculateVerticalOffset(proxy: geometry)
                        VStack(spacing: 35) {
                            NavigationLink {
                                CreateScrapbookView(fbVM: fbVM, userVM: userVM, scrapbook: scrapbook)
                            } label: {
                                JournalCover(template: scrapbook.template, degrees: 0, title: scrapbook.name, showOnlyCover: $showOnlyCover)
                                    .scaleEffect(scaleEffect)
                                    .frame(width: UIScreen.main.bounds.width * 0.92 * scaleEffect, height: UIScreen.main.bounds.height * 0.56 * scaleEffect)
                                    .transition(.identity)
                                    .matchedGeometryEffect(id: "journal_\(scrapbook.id)", in: shelfNamespace, properties: .position, anchor: .center)
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
                            .frame(width: 200)
                        }
                        .frame(width: 240, height: 700)
                        .offset(y: verticalOffset)
                    }
                    .frame(width: 240, height: 600)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 500, alignment: .bottom)
        .padding(.top, 30)

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
            ])], scrapbookShelves: [])), shelf: ScrapbookShelf(name: "Scrapshelf", scrapbooks: [Scrapbook(name: "Scrapbook1", id: UUID(), createdDate: "5/6/2026", category: "", isSaved: true, isShared: false, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [ScrapbookPage(number: 1, entries: [ScrapbookEntry(id: UUID(), type: "text", position: [0, 0, -2], scale: 1.0, rotation: [0.0, 0.0, 0.0, 0.0], text: "Hello", imageURL: nil)], entryCount: 2)], currentPage: 0)]), aiVM: AIViewModel(), fbVM: FirebaseViewModel(), shelfIndex: 0, selectedOption: $selectedOption)
        }
    }

    return Preview()
}
