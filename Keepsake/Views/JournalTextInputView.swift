//
//  JournalTextInputView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/26/25.
//

import SwiftUI

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
    var entry: JournalEntry
    var body: some View {
        VStack {
            Button {
                Task {
                    var newEntry = JournalEntry(date: date, title: title, text: inputText, summary: "")
                    newEntry.summary = await aiVM.summarize(entry: newEntry) ?? String(inputText.prefix(15))
                    
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
            TextField("", text: $title, axis: .vertical)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 4)
            Text(date).font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
            TextEditor(text: $inputText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 4)
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
                Button(action: {
                    
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.black)
                            .fill(LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .leading, endPoint: .trailing))
                            .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.1)
                        Text("Chat with Chatbot")
                            .foregroundStyle(.black)
                            
                    }
                })
            }.padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                .padding(.bottom, 10)
        }.onAppear() {
            title = entry.title
            inputText = entry.text
            date = entry.date
        }
    }
}

#Preview {
    struct Preview: View {
        @State var inTextEntry = false
        var body: some View {
            JournalTextInputView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")]), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")]), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")]), JournalPage(number: 5, entries: [])]),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])]),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1, entries: []), JournalPage(number: 2, entries: []), JournalPage(number: 3, entries: []), JournalPage(number: 4, entries: []), JournalPage(number: 5, entries: [])])
            ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), aiVM: AIViewModel(), shelfIndex: 0, journalIndex: 0, entryIndex: 0, pageIndex: 2, inTextEntry: $inTextEntry, entry: JournalEntry(date: "01/02/2024", title: "Oh my world", text: "I have started to text", summary: "summary"))
        }
    }

    return Preview()
}

