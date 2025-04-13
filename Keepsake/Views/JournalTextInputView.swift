//
//  JournalTextInputView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/26/25.
//

import SwiftUI
import Combine

struct JournalTextInputView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    var shelfIndex: Int
    var journalIndex: Int
    var entryIndex: Int
    var pageIndex: Int
    @State var title: String = ""
    @State var date: String = ""
    @State var inputText: String = ""
    @Binding var inEntry: EntryType
    var textfieldPrompt: String = "Enter Title"
    var entry: WrittenEntry
    @State var showPromptSheet: Bool = false
    @State var selectedPrompt: String? = ""
    @State private var shouldNavigate = false
    @Binding var dailyPrompt: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        Task {
                            if entry.summary == "***" {
                                userVM.removeJournalEntry(page: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).pages[pageIndex], index: entryIndex)
                            }
                            await MainActor.run {
                                inEntry = .openJournal
                            }
                        }
                    }
                    label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.black)
                    }.padding(UIScreen.main.bounds.width * 0.025)
                    Spacer()
                    Button {
                        Task {
                            print(entry.width, entry.title)
                            var newEntry = WrittenEntry(date: date, title: title, text: inputText, summary: entry.summary, width: entry.width, height: entry.height, isFake: false, color: entry.color)
                            if entry.text != inputText {
                                newEntry.summary = await aiVM.summarize(entry: newEntry) ?? String(inputText.prefix(15))
                            }
                            
                            userVM.updateJournalEntry(shelfIndex: shelfIndex, bookIndex: journalIndex, pageNum: pageIndex, entryIndex: entryIndex, newEntry: newEntry)
                            for entry in userVM.user.journalShelves[shelfIndex].journals[journalIndex].pages[pageIndex].entries {
                                print(entry.width, entry.height, entry.title, entry.id)
                            }
                            await fbVM.updateJournalPage(entries: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).pages[pageIndex].entries, journalID: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).id, pageNumber: pageIndex)
                            
                            await MainActor.run {
                                inEntry = .openJournal
                            }
                        }
                    }
                    label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.black)
                    }.padding(UIScreen.main.bounds.width * 0.025)
                }
                TextField(textfieldPrompt, text: $title, axis: .vertical)
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 2)
                Text(date).font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                if let selectedPrompt = selectedPrompt, !selectedPrompt.isEmpty {
                    let trimmedPrompt = selectedPrompt.trimmingCharacters(in: .whitespacesAndNewlines)

                    HStack(spacing: 8) {
                        // Vertical bar
                        Rectangle()
                            .frame(width: 4, height: 40) // Adjust width for the vertical bar thickness
                            .foregroundColor(.blue) // Bar color

                        // Prompt text
                        Text(trimmedPrompt)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color.clear) // No need for a background box, just the bar
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                }
                DebounceTextField(inputText: $inputText, aiVM: aiVM)
                Spacer()
                HStack() {
                    Button {
                        showPromptSheet = true
                    } label: {
                        Label("need suggestions?", systemImage: "lightbulb.max")
                            .foregroundColor(Color(red: 127/255, green: 210/255, blue: 231/255))
                    }
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                    .padding(.bottom, 20)
                    Spacer()
                }
            }.onAppear() {
                title = entry.title
                inputText = entry.text
                date = entry.date
            }
            .sheet(isPresented: $showPromptSheet) {
                SuggestedPromptsView(aiVM: aiVM, selectedPrompt: $selectedPrompt, isPresented: $showPromptSheet)
            }
        }
        .onAppear {
            if let dailyPrompt = dailyPrompt {
                selectedPrompt = dailyPrompt
            }
        }
        .onChange(of: dailyPrompt) {
            if let dailyPrompt = dailyPrompt {
                selectedPrompt = dailyPrompt
            }
        }
        .onDisappear {
            dailyPrompt = nil
        }
    }
}

struct DebounceTextField: View {
    @State var publisher = PassthroughSubject<String, Never>()
    @Binding var inputText: String
    var valueChanged: ((_ value: String) -> Void)?
    @State var debounceSeconds = 2
    @State private var suggestion: String = ""
    @ObservedObject var aiVM: AIViewModel
    @State private var loadingDots = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // The actual TextEditor for user input
            TextEditor(text: $inputText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 4)
                .background(Color.clear)
                .overlay(
                    Group {
                        if inputText.isEmpty {
                            Text("Start typing...")
                                .foregroundColor(Color.gray.opacity(0.5))
                                .italic()
                                .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 2)
                                .padding(.top, 8) // Adjust to align with text input
                                .allowsHitTesting(false) // Ensures text input is still interactive
                        }
                    }, alignment: .topLeading
                    )
                .onChange(of: inputText) { _, newValue in
                    publisher.send(newValue)
                }
                .onReceive(
                    publisher.debounce(
                        for: .seconds(debounceSeconds),
                        scheduler: DispatchQueue.main
                    )
                ) { value in
                    if let valueChanged = valueChanged {
                        valueChanged(value)
                    }
                    // Fetch the suggestion from the AI model
                    if value != "" {
                        Task {
                            isLoading = true
                            let completion = await aiVM.topicCompletion(journalText: value)
                            suggestion = completion ?? ""
                            isLoading = false
                        }
                    } else {
                        isLoading = false
                        suggestion = ""
                    }
                }
            
            // Display the suggestion as grayed-out phantom text
            if isLoading {
                Text("Thinking\(loadingDots)")
                    .font(.body)
                    .foregroundColor(Color.gray.opacity(0.8))
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 4)
                    .padding(.top, 10)
                    .opacity(0.5)
                    .italic()
                    .onAppear {
                        startLoadingAnimation()
                    }
            } else if !suggestion.isEmpty {
                Text(suggestion)
                    .font(.body)
                    .foregroundColor(Color.gray.opacity(0.8))
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 4)
                    .padding(.top, 10)
                    .opacity(0.5)
                    .italic()
                    .zIndex(1)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private func startLoadingAnimation() {
        loadingDots = ""
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if !isLoading {
                timer.invalidate()
                return
            }
            if loadingDots.count >= 3 {
                loadingDots = ""
            } else {
                loadingDots.append(".")
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var inEntry: EntryType = .openJournal
        var body: some View {
            JournalTextInputView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), WrittenEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [WrittenEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), WrittenEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), aiVM: AIViewModel(), fbVM: FirebaseViewModel(), shelfIndex: 0, journalIndex: 0, entryIndex: 0, pageIndex: 2, inEntry: $inEntry, textfieldPrompt: "Enter Prompt", entry: WrittenEntry(date: "01/02/2024", title: "Oh my world", text: "I have started to text", summary: "summary"), selectedPrompt: "Summarize the highlights of your day and any moments of learning", dailyPrompt: .constant(nil))
        }
    }

    return Preview()
}


