//
//  JournalTextInputView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/26/25.
//

import SwiftUI

struct JournalTextInputView: View {
    @State var title: String = "Prompt"
    @State var date: String = "01-01-2025"
    @State var inputText: String = ""
    @Binding var inTextEntry: Bool
    var body: some View {
        VStack {
            Button {
                inTextEntry.toggle()
                
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.black)
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(UIScreen.main.bounds.width * 0.025)
            Text(title).font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
            Text(date).font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
            TextEditor(text: $inputText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05 - 4)
            Spacer()
            HStack() {
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.black)
                    .frame(width: UIScreen.main.bounds.width * 0.1)
                    .contextMenu {
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
        }
    }
}

#Preview {
    struct Preview: View {
        @State var inTextEntry = false
        var body: some View {
            JournalTextInputView(inTextEntry: $inTextEntry)
        }
    }

    return Preview()
}

