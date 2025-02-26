//
//  SuggestedPromptsView.swift
//  Keepsake
//
//  Created by Holden Casey on 2/24/25.
//

import SwiftUI

struct SuggestedPromptsView: View {
    var explorePrompts: [String] = []
    var savedPrompts: [String] = []
    @State private var exploreOrSaved = 0
    
    var body: some View {
        VStack {
            Picker("Period", selection: $exploreOrSaved) {
                Text("explore").tag(0)
                Text("saved").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Spacer()
            HStack{
                Text("""
                Feeling unmotivated?
                Try some of these
                suggested prompts
                """)
                .font(.title3)
                .foregroundStyle(Color.gray)
                .fontWeight(.bold)
                .padding()
                .padding(.horizontal)
                Spacer()
            }
            List{
                let prompts = exploreOrSaved == 0 ? explorePrompts : savedPrompts
                ForEach(prompts, id: \.self) { prompt in
                    VStack (alignment: .leading) {
                        HStack {
                            Text(prompt)
                                .font(.headline)
                                .padding()
                                .padding(.vertical)
                                .lineLimit(3)
                                
                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            print("Button clicked")
                        } label: {
                            Text("choose prompt?")
                                .font(.title3)
                           // COLOR NOT WORKING FOR SOME REASON
                                .foregroundStyle(Color.gray)
                        }
                        .tint(.clear)
                    }
                    .listRowSeparator(.hidden)
                    .padding(.bottom)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
        .background(Color.gray.opacity(0.3))
    }
}

#Preview {
    SuggestedPromptsView(explorePrompts: ["Reflect on your day", "Write about your passion for baseball", "Journal about your gratitude"], savedPrompts: ["Saved1", "Saved2"])
}
