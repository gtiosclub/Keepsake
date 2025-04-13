//
//  ConversationView.swift
//  Keepsake
//
//  Created by Shlok Patel on 3/2/25.
//

import SwiftUI

struct ConversationView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    var convoEntry: ConversationEntry
    @Binding var inEntry: EntryType
    var shelfIndex: Int
    var journalIndex: Int
    var entryIndex: Int
    var pageIndex: Int
    @State var title: String = ""
    @State var date: String = ""
    var textfieldPrompt: String = "Untitled Conversation"
    @State private var isSaving: Bool = false

    
    
    @State private var displayedMessages: [String] = []

    var body: some View {
        NavigationStack {
            ZStack {
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
                        
                        
                        Spacer()
                        
                        Button {
                            Task {
                                isSaving = true
                                var updatedEntry = convoEntry
                                updatedEntry.conversationLog = aiVM.conversationHistory
                                updatedEntry.title = title
                                
                                userVM.updateJournalEntry(
                                    shelfIndex: shelfIndex,
                                    bookIndex: journalIndex,
                                    pageNum: pageIndex,
                                    entryIndex: entryIndex,
                                    newEntry: updatedEntry
                                )
                                
                                await fbVM.updateJournalPage(entries: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).pages[pageIndex].entries, journalID: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).id, pageNumber: pageIndex)
                                
                                await MainActor.run {
                                    isSaving = false
                                    inEntry = .openJournal
                                }
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.black)
                        }
                        .padding(UIScreen.main.bounds.width * 0.025)
                    }
                    
                    
                    TextField(textfieldPrompt, text: $title, axis: .vertical)
                        .fontWeight(.bold)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 2)
                    
                    Text(date).font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 30) {
                                ForEach(Array(displayedMessages.enumerated()), id: \.offset) { index, message in
                                    if message.starts(with: "User:") {
                                        HStack {
                                            HStack(spacing: 5) {
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
                        .onChange(of: displayedMessages) { newDisplayed in
                            if !newDisplayed.isEmpty {
                                withAnimation {
                                    proxy.scrollTo(newDisplayed.count - 1, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: aiVM.conversationHistory) { newHistory in
                            displayedMessages = newHistory
                            
                            //                        Task {
                            //                            let success = await fbVM.addConversationLog(text: newHistory, journalEntry: convoEntry.id)
                            //                            if !success {
                            //                                print("Failed to update conversation log in Firestore.")
                            //                            }
                            //                        }
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
                
                if isSaving {
                    VStack {
                        ProgressView("Saving...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                    }
                }
            }
        }
        .onAppear {
            Task {
                let loaded = await fbVM.loadConversationLog(
                    for: convoEntry.id.uuidString,
                    aiVM: aiVM
                )
                
                title = convoEntry.title
                date = convoEntry.date
                
                if !loaded && !convoEntry.conversationLog.isEmpty {
                    aiVM.conversationHistory = convoEntry.conversationLog
                }
                
                if aiVM.conversationHistory.isEmpty {
                    await aiVM.startConversation(entry: convoEntry)
                }
                
                await MainActor.run {
                    displayedMessages = aiVM.conversationHistory
                }
            }
        }
    }
}

#Preview {
    ConversationView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
        Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
    ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), aiVM: AIViewModel(), fbVM: FirebaseViewModel(), convoEntry: ConversationEntry(date: "01/02/2024", title: "Oh my world", conversationLog: []), inEntry: .constant(EntryType.openJournal), shelfIndex: 0, journalIndex: 0, entryIndex: 0, pageIndex: 2)
}
