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
    @ObservedObject var viewModel: AIViewModel
    @ObservedObject var FBviewModel: FirebaseViewModel
    var convoEntry: JournalEntry
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(viewModel.conversationHistory, id: \.self) { message in
                        let messageID = UUID()
                        if message.starts(with: "User:") {
                            HStack {
                                HStack (spacing: 5){
                                    Image(systemName: "pencil")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 30))
                                    Text(message.replacingOccurrences(of: "User: ", with: ""))
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 5)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .id(messageID)
                                
                                
                            }
                            
                            
                        } else {
                            HStack {
                                HStack {
                                    Image(systemName: "person.wave.2")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 5)
                                    Text(message.replacingOccurrences(of: "GPT: ", with: ""))
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                    Spacer()
                                }
                                .id(messageID)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: viewModel.conversationHistory) { newHistory in
                if let lastMessage = viewModel.conversationHistory.last {
                    proxy.scrollTo(lastMessage, anchor: .bottom)
                }
                Task {
                    let success = await FBviewModel.addConversationLog(text: newHistory, journalEntry: convoEntry.id)
                        if !success {
                            print("Failed to update conversation log in Firestore.")
                        }
                }
            }
            .background(Color.white)
        }
        .onAppear {
            Task {
                await FBviewModel.loadConversationLog(for: convoEntry.id.uuidString, viewModel: viewModel)
                
                if viewModel.conversationHistory.isEmpty {
                    await viewModel.startConversation(entry: convoEntry)
                }
            }
        }
        
        HStack {
            TextField("Type to chat...", text: $viewModel.userInput)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 1)
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                Button(action: {
                    Task {
                        await viewModel.sendMessage(entry: convoEntry)
                    }
                }) {
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


#Preview {
    ConversationView(viewModel: AIViewModel(), FBviewModel: FirebaseViewModel(), convoEntry: JournalEntry())
}
