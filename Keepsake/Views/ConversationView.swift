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
    var conversationEntry = ConversationEntry(date: "2/14/25", title: "Midnight Thoughts", conversationLog: [])
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.conversationHistory, id: \.self) { message in
                    if message.starts(with: "User:") {
                        HStack {
                            VStack(alignment: .trailing, spacing: 2) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 5)
                                
                                HStack (spacing: 5){
                                    Image(systemName: "pencil")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 30))
                                    Text(message.replacingOccurrences(of: "User: ", with: ""))
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                }.frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
                        }
                    
        
                    } else {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Image(systemName: "circle")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 5)
                                HStack {
                                    Text(message.replacingOccurrences(of: "GPT: ", with: ""))
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color.white)
        .onAppear {
            Task {
                await viewModel.startConversation(entry: conversationEntry)
            }
        }
        
        // Input Area
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
                        await viewModel.sendMessage(entry: conversationEntry)
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
    ConversationView(viewModel: AIViewModel())
}
