//
//  JournalEntryView.swift
//  Keepsake
//
//  Created by Ganden Fung on 2/10/25.
//

import SwiftUI

struct JournelEntryView: View {
    @State private var text: String = ""
    @State private var prompt_text : String = ""
    @State private var date_text : String = ""
    @FocusState private var isEditing: Bool

    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 300, height: 100)
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Date:")
                            .font(.headline)
                        TextField("Enter date", text: $date_text)
                    }

                    HStack {
                        Text("Prompt:")
                            .font(.headline)
                        TextField("Enter prompt", text: $prompt_text)
                    }
                }
                .padding(.horizontal, 10)
                .frame(width: 300, height: 100)
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                    .fill(Color.blue)
                    .frame(width: 300, height: 200)
                    .onTapGesture {
                        isEditing = true
                    }
                TextEditor(text: $text)
                    .padding(10)
                    .foregroundColor(.white)
                    .focused($isEditing)
                    .background(Color.blue)
                    .scrollContentBackground(.hidden)
                    //.background(Color.clear)
                    .frame(width: 300, height: 200)
                    .tint(.yellow)
            }

        }
        .padding()
    }
}

#Preview {
    JournelEntryView()
}
