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
    var shelfIndex: Int
    var journalIndex: Int
    var entryIndex: Int
    var pageIndex: Int
    @State var title: String = ""
    @State var date: String = ""
    @State var inputText: String = ""
    @Binding var inTextEntry: Bool
    var textfieldPrompt: String = "Enter Prompt"
    var entry: JournalEntry
    @State var showPromptSheet: Bool = false
    @State var selectedPrompt: String? = ""
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    Task {
                        var newEntry = JournalEntry(date: date, title: title, text: inputText, summary: entry.summary, width: entry.width, height: entry.height, isFake: false, color: entry.color)
                        if entry.text != inputText {
                            newEntry.summary = await aiVM.summarize(entry: newEntry) ?? String(inputText.prefix(15))
                        }
                        
                        userVM.updateJournalEntry(shelfIndex: shelfIndex, bookIndex: journalIndex, pageNum: pageIndex, entryIndex: entryIndex, newEntry: newEntry)
                    
                        await MainActor.run {
                            inTextEntry.toggle()
                        }
                    }
                }
                label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(UIScreen.main.bounds.width * 0.025)
                TextField(textfieldPrompt, text: $title, axis: .vertical)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 4)
                Text(date).font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                if selectedPrompt != nil {
                    if !selectedPrompt!.isEmpty {
                        let trimmedPrompt: String = selectedPrompt!.trimmingCharacters(in: .whitespacesAndNewlines)
                        Text(trimmedPrompt).font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                    }
                }
                DebounceTextField(inputText: $inputText, aiVM: aiVM)
                Spacer()
                HStack() {
                    Menu {
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Choose Photo")
                                Spacer()
                                Image(systemName: "photo")
                            }
                        }
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Take Photo")
                                Spacer()
                                Image(systemName: "camera")
                            }
                        }
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Voice Memo")
                                Spacer()
                                Image(systemName: "waveform")
                            }
                        }
                        Button {
                            showPromptSheet = true
                        } label: {
                            HStack {
                                Text("Need Suggestions?")
                                Spacer()
                                Image(systemName: "lightbulb")
                            }
                        }
                        
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.black)
                            .frame(width: UIScreen.main.bounds.width * 0.1)
                            .contextMenu {
                                
                            }
                    }
                    Spacer()
                    NavigationLink(destination: ConversationView(viewModel: aiVM)) {
                        Text("Chat with Companion")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }.padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                    .padding(.bottom, 10)
            }.onAppear() {
                title = entry.title
                inputText = entry.text
                date = entry.date
            }
            .sheet(isPresented: $showPromptSheet) {
                SuggestedPromptsView(aiVM: aiVM, selectedPrompt: $selectedPrompt, isPresented: $showPromptSheet)
            }
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
        @State var inTextEntry = false
        var body: some View {
            JournalTextInputView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), aiVM: AIViewModel(), shelfIndex: 0, journalIndex: 0, entryIndex: 0, pageIndex: 2, inTextEntry: $inTextEntry, textfieldPrompt: "Enter Prompt", entry: JournalEntry(date: "01/02/2024", title: "Oh my world", text: "I have started to text", summary: "summary"), selectedPrompt: "Summarize the highlights of your day and any moments of learning")
        }
    }

    return Preview()
}

