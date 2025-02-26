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
    var body: some View {
        VStack {
            Text(title).font(.headline)
                .frame(width: UIScreen.main.bounds.width)
            Text(date).font(.subheadline)
            TextEditor(text: $inputText)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
            Spacer()
        }
    }
}

#Preview {
    JournalTextInputView()
}
