//
//  ConversationView.swift
//  Keepsake
//
//  Created by Shlok Patel on 3/2/25.
//

import SwiftUI

//struct TypingTextView: View {
//    let fullText: String
//    @State private var displayedText = ""
//
//    var body: some View {
//        Text(displayedText)
//            .font(.custom("Noteworthy", size: 20)) // Typewriter Font for AI
//            .foregroundColor(.black.opacity(0.8))
//            .padding(.vertical, 5)
//            .onAppear {
//                startTypingAnimation()
//            }
//    }
//
//    func startTypingAnimation() {
//        displayedText = ""
//        let characters = Array(fullText)
//        var index = 0
//
//        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
//            if index < characters.count {
//                displayedText.append(characters[index])
//                index += 1
//            } else {
//                timer.invalidate() // Stop when done
//            }
//        }
//    }
//}

struct ConversationView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    var convoEntry: JournalEntry
    @Binding var inEntry: EntryType
    var shelfIndex: Int
    var journalIndex: Int
    var entryIndex: Int
    var pageIndex: Int

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        Task {
                            await MainActor.run {
                                inEntry = .openJournal
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.black)
                    }
                    .padding(UIScreen.main.bounds.width * 0.025)
                    
                    HStack(spacing: 8) {
                        Text("Echo 🌐")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Button {
                        Task {
                                    var updatedEntry = convoEntry
                                    updatedEntry.conversationLog = aiVM.conversationHistory
                                    
                                    userVM.updateJournalEntry(
                                        shelfIndex: shelfIndex,
                                        bookIndex: journalIndex,
                                        pageNum: pageIndex,
                                        entryIndex: entryIndex,
                                        newEntry: updatedEntry
                                    )
                                    
                                    let success = await fbVM.addConversationLog(
                                        text: aiVM.conversationHistory,
                                        journalEntry: convoEntry.id // Use original ID
                                    )
                                    
                                    if success {
                                        await fbVM.updateJournalPage(
                                            entries: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).pages[pageIndex].entries,
                                            journalID: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).id,
                                            pageNumber: pageIndex
                                        )
                                    }
                                    
                                    await MainActor.run {
                                        inEntry = .openJournal
                                    }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.black)
                    }
                    .padding(UIScreen.main.bounds.width * 0.025)
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(Array(aiVM.conversationHistory.enumerated()), id: \.offset) { index, message in
                                if message.starts(with: "User:") {
                                    HStack {
                                        HStack(spacing: 5) {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 30))
                                            Text(message.replacingOccurrences(of: "User: ", with: ""))
                                                .padding()
                                                .background(Color(hex: "#5abbd1").opacity(0.8))
                                                .cornerRadius(15)
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.gray)
                                                .padding(.bottom, 5)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .id(index)
                                    }
                                } else {
                                    HStack {
                                        HStack {
                                            Text("🌐")
                                                .font(.system(size: 30))
                                                .foregroundColor(.gray)
                                                .padding(.bottom, 5)
                                            Text(message.replacingOccurrences(of: "GPT: ", with: ""))
                                                .padding()
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(15)
                                            Spacer()
                                        }
                                        .id(index)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onAppear {
                        if !aiVM.conversationHistory.isEmpty {
                            withAnimation {
                                proxy.scrollTo(aiVM.conversationHistory.count - 1, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: aiVM.conversationHistory) { newHistory in
                        if !newHistory.isEmpty {
                            withAnimation {
                                proxy.scrollTo(newHistory.count - 1, anchor: .bottom)
                            }
                        }
                        Task {
                            let success = await fbVM.addConversationLog(text: newHistory, journalEntry: convoEntry.id)
                            if !success {
                                print("Failed to update conversation log in Firestore.")
                            }
                        }
                    }
                    .background(Color.white)
                }

                HStack {
                    TextField("Type to chat...", text: $aiVM.userInput)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                    if aiVM.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Button {
                            Task {
                                await aiVM.sendMessage(entry: convoEntry)
                            }
                        } label: {
                            Image(systemName: "paperplane")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.white)
            }
        }
        .onAppear {
            Task {
                let loaded = await fbVM.loadConversationLog(
                    for: convoEntry.id.uuidString,
                    aiVM: aiVM
                )
                
                if !loaded && !convoEntry.conversationLog.isEmpty {
                    aiVM.conversationHistory = convoEntry.conversationLog
                }
                
                if aiVM.conversationHistory.isEmpty {
                    await aiVM.startConversation(entry: convoEntry)
                }
            }
        }
    }
}

#Preview {
    ConversationView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
        Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
    ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), aiVM: AIViewModel(), fbVM: FirebaseViewModel(), convoEntry: JournalEntry(date: "01/02/2024", title: "Oh my world", text: "I have started to text", summary: "summary"), inEntry: .constant(EntryType.openJournal), shelfIndex: 0, journalIndex: 0, entryIndex: 0, pageIndex: 2)
}
