//
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
    @State var inTextEntry: Bool = false
    @State var selectedEntry: Int = 0
    @State var displayPage: Int = 2
    @State private var showJournalForm = false
    @Binding var selectedOption: ViewOption
    var body: some View {
        if !show {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Button {
                        selectedOption = .library
                    } label: {
                        HStack(spacing: 0) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.black)
                            Text("Library")
                                .foregroundStyle(.black)
                        }.padding(.leading, 5)
                    }
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
                            Image(systemName: "plus.circle")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        .padding(.trailing, 30)
                    }
                }
                
                Text("What is on your mind today?")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil) // Allow multiple lines
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 30)
                
                //Journals
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 45) {
                        ForEach(userVM.user.getJournalShelves()[shelfIndex].journals.indices, id: \.self) { index in
                            GeometryReader { geometry in
                                let verticalOffset = calculateVerticalOffset(proxy: geometry)
                                VStack(spacing: 35) {
                                    JournalCover(template: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: index).template, degrees: 0, title: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: index).name)
                                        .scaleEffect(scaleEffect)
                                        .frame(width: UIScreen.main.bounds.width * 0.92 * scaleEffect, height: UIScreen.main.bounds.height * 0.56 * scaleEffect)
                                        .transition(.identity)
                                        .matchedGeometryEffect(id: "journal_\(index)", in: shelfNamespace, properties: .position, anchor: .center)
                                        .onTapGesture {
                                            //print(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: index))
                                            selectedJournal = index
                                            displayPage = userVM.getJournal(shelfIndex: shelfIndex, bookIndex: index).currentPage
                                            
                                            Task {
                                                await aiVM.fetchSmartPrompts(for: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: index), count: 5)
                                            }
                                            
                                            withAnimation(.linear(duration: 0.7)) {
                                                show.toggle()
                                            } completion: {
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
                                                    }
                                                }
                                            }
                                        }
                                    VStack(spacing: 10) {
                                        //Journal name, date, created by you
                                        Text(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: index).name)
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                        
                                        Text(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: index).createdDate)
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
                .frame(height: 500)
            }
            //            .onAppear() {
            //                print(userVM.user.journalShelves)
            //            }
            .frame(maxHeight: .infinity, alignment: .top)
            .sheet(isPresented: $showJournalForm) {
                JournalFormView(
                    isPresented: $showJournalForm,
                    onCreate: { title, coverColor, pageColor, titleColor, texture in
                        Task {
                            await createJournal(
                                from: Template(name: title, coverColor: coverColor, pageColor: pageColor, titleColor: titleColor, texture: texture),
                                shelfIndex: shelfIndex, shelfID: shelf.id
                            )
                        }
                    },
                    templates: userVM.user.savedTemplates
                )
            }
        } else {
            if !inTextEntry {
                OpenJournal(userVM: userVM, fbVM: fbVM,
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
                          inTextEntry: $inTextEntry,
                          selectedEntry: $selectedEntry
                          )
                    .matchedGeometryEffect(id: "journal_\(selectedJournal)", in: shelfNamespace, properties: .position, anchor: .center)
                    .scaleEffect(scaleEffect)
                    .transition(.slide)
                    .frame(width: UIScreen.main.bounds.width * 0.92 * scaleEffect, height: UIScreen.main.bounds.height * 0.56 * scaleEffect)
                    .navigationBarBackButtonHidden(true)
            } else {
                JournalTextInputView(userVM: userVM,
                                     aiVM: aiVM, fbVM: fbVM,
                                   shelfIndex: shelfIndex,
                                   journalIndex: selectedJournal,
                                   entryIndex: selectedEntry,
                                   pageIndex: displayPage,
                                   inTextEntry: $inTextEntry,
                                   entry: userVM.getJournalEntry(shelfIndex: shelfIndex, bookIndex: selectedJournal, pageNum: displayPage, entryIndex: selectedEntry))
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    func createJournal(from template: Template, shelfIndex: Int, shelfID: UUID) async {
        let newJournal = Journal(
            name: template.name,
            createdDate: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            entries: [],
            category: "General",
            isSaved: false,
            isShared: false,
            template: template,
            pages: [JournalPage(number: 1)],
            currentPage: 0
        )
        userVM.addJournalToShelf(journal: newJournal, shelfIndex: shelfIndex)
        await fbVM.addJournal(journal: newJournal, journalShelfID: shelfID)
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
            ShelfView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ]), JournalShelf(name: "Shelf 2", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .flower1), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 2), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ])], scrapbookShelves: [])), shelf: JournalShelf(name: "Bookshelf", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ]), aiVM: AIViewModel(), fbVM: FirebaseViewModel(), shelfIndex: 0, selectedOption: $selectedOption)
        }
    }

    return Preview()
}
