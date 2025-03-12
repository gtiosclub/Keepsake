//
//  JournalVoiceMemoInputView.swift
//  Keepsake
//
//  Created by Holden Casey on 3/12/25.
//

import SwiftUI

struct JournalVoiceMemoInputView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    var shelfIndex: Int
    var journalIndex: Int
    var entryIndex: Int
    var pageIndex: Int
    @State var title: String = ""
    @State var date: String = ""
//    @State var voiceRecording: AudioRecording
    @State var transcription: String = ""
    var entry: JournalEntry
    @State var showPromptSheet: Bool = false
    @State var selectedPrompt: String? = ""
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//#Preview {
//    JournalVoiceMemoInputView()
//}
