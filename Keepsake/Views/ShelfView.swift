////
//  JournalView.swift
//  Keepsake
//
//  Created by Chaerin Lee on 2/5/25.
//
import SwiftUI

struct ShelfView: View {
    @Namespace private var shelfNamespace
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var shelf: JournalShelf
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    var shelfIndex: Int
    @State var degrees: CGFloat = 0
    @State var frontDegrees: CGFloat = 0
    @State var show: Bool = false
    @State var selectedJournal = 0
    @State var bind: Int?
    @State var coverZ: Double = 0
    @State var circleStart: CGFloat = 0.5
    @State var circleEnd: CGFloat = 0.5
    @State var ellipseStart: CGFloat = 1
    @State var ellipseEnd: CGFloat = 1
    @State var scaleEffect: CGFloat = 0.6
    @State var isHidden: Bool = false
    @State var inEntry: EntryType = .openJournal
    @State var selectedEntry: Int = 0
    @State var displayPage: Int = 2
    @State private var showJournalForm = false
    @Binding var selectedOption: ViewOption
    @State var showDeleteButton: Bool = false
    @State var deleteJournalID: String = ""
    @State var hideToolBar: Bool = false
    @State var dailyPrompt: String? = nil
    @State var showOnlyCover: Bool = true
    @State var isAnimating: Bool = false
    @State var currentScrollIndex = 0
    var body: some View {
        ZStack {
            if !show {
                shelfParent
                    .ignoresSafeArea(.container, edges: .top)
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.linear),
                        removal: .opacity.animation(.linear.delay(0.2))
                    ))
            } else {
                switch(inEntry) {
                case .written:
                    written
                        .transition(.identity)
                case .voice:
                    voice
                        .transition(.identity)
                case .chat:
                    chat
                        .transition(.identity)
                default:
                    openJournalView
                        
                }
            }
        }
        .background(
            Group {
                if !show {
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
                            .animation(.easeOut(duration: 0.3).delay(0.5), value: show)// <-- delay re-entry
                    }.frame(maxHeight: .infinity, alignment: .top)
                        .ignoresSafeArea(.container, edges: .top)
                }
            }
        )
    }
    
    private var shelfParent: some View {
        VStack(alignment: .leading, spacing: 10) {
            topVStack
                .transition(
                    .opacity
                        .animation(.easeIn(duration: 0.5)) // Fast appear
                )
                .padding(.top, 70)
            textView
                .transition(
                    .opacity
                        .animation(.easeIn(duration: 0.5)) // Fast appear
                )
                .padding(.bottom, 10)
            buttonNavigationView
                .transition(.opacity.animation(.easeIn(duration: 0.5)))
                .padding(.bottom, 50)
            if shelf.journals.count == 0 {
                defaultScrollView
                    .padding(.top, UIScreen.main.bounds.height * -0.05)
            } else {
                scrollView
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
        //            .onAppear() {
        //                print(userVM.user.journalShelves)
        //            }
        .frame(maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $showJournalForm) {
            JournalFormView(
                isPresented: $showJournalForm,
                onCreate: { title, coverColor, pageColor, titleColor, texture, journalPages in
                    Task {
                        await createJournal(
                            from: Template(name: title, coverColor: coverColor, pageColor: pageColor, titleColor: titleColor, texture: texture, journalPages: journalPages),
                            shelfIndex: shelfIndex, shelfID: shelf.id
                        )
                    }
                },
                templates: userVM.user.savedTemplates, userVM: userVM, fbVM: fbVM
            )
        }
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
                
                Button(action: { showJournalForm = true }) {
                     Image(systemName: "plus")
                         .font(.system(size: 28))
                         .foregroundColor(Color(hex: "#7FD2E7"))
                         
                }.padding(.top, 20)
                    .padding(.trailing, 30)
            }
        }
    }
    
    private var buttonNavigationView: some View {
        HStack(spacing: 26) { // Reduced spacing
            Spacer()
            
            Button(action: {
                print(userVM.getJournalShelfIndex())
            }) {
                Text("Journal")
                    .font(.system(size: 14, weight: .semibold)) // Smaller font
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#7FD2E7"))
                    .cornerRadius(12) // Smaller corner radius
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                userVM.setLastUsed(isJournal: false)
                Task {
                    await fbVM.updateUserLastUsedSShelf(user: userVM.user)
                }
                selectedOption = .scrapbook_shelf
            }) {
                Text("AR Scrapbook")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(1))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
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
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 45) {
                    ForEach(Array(userVM.user.journalShelves[shelfIndex].journals.enumerated()), id: \.element.id) { index, journal in
                        GeometryReader { geometry in
                            let verticalOffset = calculateVerticalOffset(proxy: geometry)
                            VStack(spacing: 35) {
                                ZStack {
                                    JournalCover(template: journal.template, degrees: 0, title: journal.name, showOnlyCover: $showOnlyCover, offset: true)
                                        .scaleEffect(scaleEffect)
                                        .frame(width: UIScreen.main.bounds.width * 0.92 * scaleEffect,
                                               height: UIScreen.main.bounds.height * 0.56 * scaleEffect)
                                        .matchedGeometryEffect(
                                            id: "journal_\(journal.id)",
                                            in: shelfNamespace,
                                            properties: [.position],
                                            anchor: .center
                                        )
                                }
                                .onTapGesture {
                                    if showDeleteButton {
                                        showDeleteButton.toggle()
                                    } else if !isAnimating {
                                        selectedJournal = userVM.getJournalIndex(journal: journal, shelfIndex: shelfIndex)
                                        displayPage = journal.currentPage
                                        isAnimating.toggle()
                                        Task {
                                            await aiVM.fetchSmartPrompts(for: journal, count: 5)
                                        }
                                        hideToolBar.toggle()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.linear(duration: 0.5)) {
                                                show.toggle()
                                            } completion: {
                                                showOnlyCover.toggle()
                                                withAnimation(.linear(duration: 0.7).delay(0.0)) {
                                                    scaleEffect = 1
                                                }
                                                circleStart = 1
                                                circleEnd = 1
                                                withAnimation(.linear(duration: 0.7).delay(0.0)) {
                                                    circleStart -= 0.25
                                                    degrees -= 90
                                                    frontDegrees -= 90
                                                } completion: {
                                                    coverZ = -1
                                                    isHidden = true
                                                    withAnimation(.linear(duration: 0.7).delay(0)) {
                                                        circleStart -= 0.25
                                                        degrees -= 90
                                                        frontDegrees -= 90
                                                        isAnimating.toggle()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    withAnimation(.spring()) {
                                        showDeleteButton.toggle()
                                        deleteJournalID = journal.id.uuidString
                                    }
                                }
                                if showDeleteButton && deleteJournalID == journal.id.uuidString {
                                    Button {
                                        userVM.removeJournalFromShelf(shelfIndex: shelfIndex, journalID: journal.id)
                                        Task {
                                            await fbVM.deleteJournal(journalID: journal.id.uuidString, journalShelfID: userVM.getJournalShelves()[shelfIndex].id)
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
                                    Text(journal.name)
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    Text(journal.createdDate)
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
                            let newIndex = min(max(currentScrollIndex + nextJournal,0), shelf.journals.count-1)
                            
                            withAnimation {
                                currentScrollIndex = newIndex
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
            )
        }
    }
    
    private var defaultScrollView: some View {
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
                                    showJournalForm = true
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
    
    private var openJournalView: some View {
        ZStack {
            OpenJournal(userVM: userVM, fbVM: fbVM, aiVM: aiVM,
                        journal: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: selectedJournal),
                        shelfIndex: shelfIndex,
                        bookIndex: selectedJournal,
                        degrees: $degrees,
                        isHidden: $isHidden,
                        show: $show,
                        frontDegrees: $frontDegrees,
                        circleStart: $circleStart,
                        circleEnd: $circleEnd,
                        displayPageIndex: $displayPage,
                        coverZ: $coverZ,
                        scaleFactor: $scaleEffect,
                        inEntry: $inEntry,
                        selectedEntry: $selectedEntry, hideToolBar: $hideToolBar, dailyPrompt: $dailyPrompt, showOnlyCover: $showOnlyCover, isAnimating: $isAnimating
            )
            .matchedGeometryEffect(
                id: "journal_\(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: selectedJournal).id)",
                in: shelfNamespace,
                properties: [.position],
                anchor: .center
            )
            .scaleEffect(scaleEffect)
            .transition(.slide)
            .frame(width: UIScreen.main.bounds.width * 0.92 * scaleEffect,
                   height: UIScreen.main.bounds.height * 0.56 * scaleEffect)
            .ignoresSafeArea()
        }
    }
    
    private var written: some View {
        let temp = userVM.getJournalEntry(shelfIndex: shelfIndex, bookIndex: selectedJournal, pageNum: displayPage, entryIndex: selectedEntry)
        return Group {
            if let writtenEntry = temp as? WrittenEntry {
                JournalTextInputView(
                    userVM: userVM,
                    aiVM: aiVM,
                    fbVM: fbVM,
                    shelfIndex: shelfIndex,
                    journalIndex: selectedJournal,
                    entryIndex: selectedEntry,
                    pageIndex: displayPage,
                    inEntry: $inEntry,
                    entry: writtenEntry,
                    selectedPrompt: writtenEntry.selectedPrompt,
                    dailyPrompt: $dailyPrompt
                )
            } else {
                JournalTextInputView(
                    userVM: userVM,
                    aiVM: aiVM,
                    fbVM: fbVM,
                    shelfIndex: shelfIndex,
                    journalIndex: selectedJournal,
                    entryIndex: selectedEntry,
                    pageIndex: displayPage,
                    inEntry: $inEntry,
                    entry: WrittenEntry(
                        date: "",
                        title: "",
                        text: "",
                        summary: "",
                        width: temp.width,
                        height: temp.height,
                        isFake: false,
                        color: temp.color
                    ),
                    dailyPrompt: $dailyPrompt
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var voice: some View {
        JournalVoiceMemoInputView(userVM: userVM, aiVM: aiVM, fbVM: fbVM, shelfIndex: shelfIndex, journalIndex: selectedJournal, entryIndex: selectedEntry, pageIndex: displayPage, inEntry: $inEntry, audioRecording: AudioRecording(), entry: userVM.getJournalEntry(shelfIndex: shelfIndex, bookIndex: selectedJournal, pageNum: displayPage, entryIndex: selectedEntry) as? VoiceEntry ?? VoiceEntry(date: "", title: "", audio: nil))
            .navigationBarBackButtonHidden(true)
    }
    
    private var chat: some View {
        ConversationView(userVM: userVM, aiVM: aiVM, fbVM: fbVM, convoEntry: userVM.getJournalEntry(shelfIndex: shelfIndex, bookIndex: selectedJournal, pageNum: displayPage, entryIndex: selectedEntry) as? ConversationEntry ?? ConversationEntry(date: "", title: "", conversationLog: []), inEntry: $inEntry, shelfIndex: shelfIndex, journalIndex: selectedJournal, entryIndex: selectedEntry, pageIndex: displayPage)
            .navigationBarBackButtonHidden(true)
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
        var body: some View {
            ShelfView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: []), JournalShelf(name: "Shelf 2", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ])], scrapbookShelves: [])), shelf: JournalShelf(name: "Bookshelf", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ]), aiVM: AIViewModel(), fbVM: FirebaseViewModel(), shelfIndex: 0, selectedOption: $selectedOption)
        }
    }

    return Preview()
}
