//
//  SuggestedPromptsView.swift
//  Keepsake
//
//  Created by Holden Casey on 2/24/25.
//

import SwiftUI

struct SuggestedPromptsView: View {
    @ObservedObject var aiVM: AIViewModel
    @Binding var selectedPrompt: String?
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.red)
                
                Spacer()
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 20)
            
            Text("Feeling unmotivated? Try some of these suggested prompts")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(Color.black)
            .padding(.horizontal)
            .padding(.top, 20)
            
            List{
                let prompts = aiVM.generatedPrompts
                ForEach(prompts, id: \.self) { prompt in
                    VStack (alignment: .leading) {
                        HStack {
                            Text(prompt)
                                .font(.headline)
                                .padding()
                                .padding(.vertical)
                                .lineLimit(3)
                                .foregroundStyle(Color.white)
                                
                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.32, green: 0.54, blue: 0.8))
                                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 4)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        selectedPrompt = prompt
                        isPresented = false
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
        .background(Color.white)
    }
}

#Preview {
    SuggestedPromptsView(aiVM: AIViewModel(), selectedPrompt: .constant("Reflect on your day"), isPresented: .constant(true))
}
