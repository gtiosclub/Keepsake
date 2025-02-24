//
//  SuggestedPromptsView.swift
//  Keepsake
//
//  Created by Holden Casey on 2/24/25.
//

import SwiftUI

struct SuggestedPromptsView: View {
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
            // List prompts
            List {
                VStack {
                    Text("Write about what you bought at the store last night.")
                        .font(.headline)
                        .padding()
                        .padding(.vertical)
                        .lineLimit(3)
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
                        // STOPPED WORKING HERE
                        // COLOR NOT WORKING FOR SOME REASON
                            .foregroundStyle(Color.gray)
                    }
                    .tint(.clear)
                }
            }
            .scrollContentBackground(.hidden)
            
        }
        .background(Color.gray.opacity(0.3))
    }
}

#Preview {
    SuggestedPromptsView()
}
