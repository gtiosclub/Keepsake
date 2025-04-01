//
//  JournalVoiceMemoInputView.swift
//  Keepsake
//
//  Created by Holden Casey on 3/12/25.
//

import SwiftUI
import Foundation
import AVFoundation
import Speech

struct JournalVoiceMemoInputView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    var shelfIndex: Int
    var journalIndex: Int
    var entryIndex: Int
    var pageIndex: Int
    @State var title: String = ""
    @State var date: String = ""
    @Binding var inEntry: EntryType
    @ObservedObject var audioRecording: AudioRecording
    @State var transcription: String = ""
    var entry: JournalEntry
    @State var showPromptSheet: Bool = false
    @State var selectedPrompt: String? = ""
    var body: some View {
        NavigationStack {
            HStack {
                Button {
                    Task {
                        if entry.summary == "***" {
                            userVM.removeJournalEntry(page: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).pages[pageIndex], index: entryIndex)
                        }
                        await MainActor.run {
                            inEntry = .openJournal
                        }
                    }
                }
                label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }.padding(UIScreen.main.bounds.width * 0.025)
                Spacer()
                Button {
                    Task {
                        var newEntry: JournalEntry = JournalEntry(date: date, title: title, text: audioRecording.transcript, summary: entry.summary, width: entry.width, height: entry.height, isFake: false, color: entry.color)
                        if entry.text != audioRecording.transcript {
                            newEntry.summary = await aiVM.summarize(entry: newEntry) ?? String(audioRecording.transcript.prefix(15))
                        }
                        newEntry.type = .voice
                        newEntry.audio = audioRecording.getAudioData()
                        userVM.updateJournalEntry(shelfIndex: shelfIndex, bookIndex: journalIndex, pageNum: pageIndex, entryIndex: entryIndex, newEntry: newEntry)
                        
                        await fbVM.updateJournalPage(entries: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).pages[pageIndex].entries, journalID: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: journalIndex).id, pageNumber: pageIndex)
                        
                        await MainActor.run {
                            inEntry = .openJournal
                        }
                    }
                }
                label: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.black)
                }.padding(UIScreen.main.bounds.width * 0.025)
            }
            HStack {
                Text("voice memo")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer()
            }
            VoiceRecordingView(audioRecording: audioRecording)
//                .frame(width: UIScreen.main.bounds.width / 5)
                .font(.title)
            
            if selectedPrompt != nil {
                if !selectedPrompt!.isEmpty {
                    let trimmedPrompt: String = selectedPrompt!.trimmingCharacters(in: .whitespacesAndNewlines)
                    Text(trimmedPrompt)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .padding()
                }
            }
            ScrollView {
                let transcript = audioRecording.transcript == "" ? (transcription == "" ? "Tap the microphone to start transcribing" : transcription) : audioRecording.transcript
                Text(transcript)
                    .padding()
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(nil)
            }
            HStack() {
                Menu {
                    Button {
                        showPromptSheet = true
                    } label: {
                        HStack {
                            Text("Need Suggestions?")
                            Spacer()
                            Image(systemName: "lightbulb")
                        }
                    }
                } label: {
                    Image(systemName: "lightbulb.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.1)
                        .contextMenu {
                            
                        }
                }
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                .padding(.bottom, 10)
                Spacer()
            }
        }.onAppear() {
            title = entry.title
            transcription = entry.text
            date = entry.date
        }
        .sheet(isPresented: $showPromptSheet) {
            SuggestedPromptsView(aiVM: aiVM, selectedPrompt: $selectedPrompt, isPresented: $showPromptSheet)
        }
    }
}

#Preview {
    JournalVoiceMemoInputView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
        Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
        Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
    ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), aiVM: AIViewModel(), fbVM: FirebaseViewModel(), shelfIndex: 0, journalIndex: 0, entryIndex: 0, pageIndex: 2, inEntry: .constant(EntryType.openJournal), audioRecording: AudioRecording(), entry: JournalEntry(date: "01/02/2024", title: "Oh my world", text: "I have started to text", summary: "summary"), selectedPrompt: "Summarize the highlights of your day and any moments of learning")
}

final class AudioRecording: NSObject, ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioSession = AVAudioSession.sharedInstance()

    private var audioFile: AVAudioFile?
    private var audioURL: URL?

    @Published var isRecording = false
    @Published var transcript: String = ""

    func startRecording() {
        isRecording = true
        transcript = ""

        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                print("Speech recognition not authorized")
                return
            }

            DispatchQueue.main.async {
                do {
                    try self.audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                    try self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    print("Error resetting audio session for recording: \(error)")
                }
                self.startAudioEngineWithRecordingAndTranscription()
            }
        }
    }

    private func startAudioEngineWithRecordingAndTranscription() {
        audioEngine = AVAudioEngine()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let inputNode = audioEngine?.inputNode,
              let recognitionRequest = recognitionRequest else {
            print("Failed to set up audio engine")
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine?.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isRecording = false
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Prepare file for saving audio
        let fileName = UUID().uuidString + ".caf"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioURL = documentsPath.appendingPathComponent(fileName)

        do {
            audioFile = try AVAudioFile(forWriting: audioURL!, settings: recordingFormat.settings)
        } catch {
            print("Failed to create audio file: \(error)")
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer, _) in
            self.recognitionRequest?.append(buffer)

            do {
                try self.audioFile?.write(from: buffer)
            } catch {
                print("Error writing audio buffer to file: \(error)")
            }
        }

        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioEngine?.start()
        } catch {
            print("Audio engine error: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        isRecording = false
    }

    func getAudioData() -> Data? {
        guard let url = audioURL else { return nil }
        return try? Data(contentsOf: url)
    }
    
    private var audioPlayer: AVAudioPlayer?

    func playRecording() {
        guard let url = audioURL else {
            print("Error playing audio: No audio file found")
            return
        }
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error)")
        }
    }

    func hasRecording() -> Bool {
        return audioURL != nil
    }
}

//extension Color {
//    init(hex: String) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//
//        var rgb: UInt64 = 0
//        Scanner(string: hexSanitized).scanHexInt64(&rgb)
//
//        let red = Double((rgb >> 16) & 0xFF) / 255.0
//        let green = Double((rgb >> 8) & 0xFF) / 255.0
//        let blue = Double(rgb & 0xFF) / 255.0
//
//        self.init(red: red, green: green, blue: blue)
//    }
//}

struct VoiceRecordingView: View {
    @State private var isRecording = false
    var audioRecording: AudioRecording

    var body: some View {
        VStack(spacing: 12) {
            // Record Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isRecording.toggle()
                    if audioRecording.isRecording {
                        audioRecording.stopRecording()
                    } else {
                        audioRecording.startRecording()
                    }
                }
            }) {
                recordingButton
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: UIScreen.main.bounds.width / 5)

            // Playback Button – only show if audio exists
            if audioRecording.hasRecording() {
                Button(action: {
                    audioRecording.playRecording()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Play Recording")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#FFADF4").opacity(0.2))
                    )
                    .foregroundColor(Color(hex: "#FFADF4"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#FFADF4"), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut, value: audioRecording.hasRecording())
    }

    private var recordingButton: some View {
        let animatedOverlay = Circle()
            .stroke(Color.white.opacity(audioRecording.isRecording ? 0.5 : 0), lineWidth: 5)
            .scaleEffect(isRecording ? 1.3 : 1.0)
            .opacity(isRecording ? 0 : 1)
            .animation(isRecording ? Animation.easeOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isRecording)

        return ZStack {
            Circle()
                .fill(isRecording ? Color(hex: "#FFADF4").opacity(0.7) : Color(hex: "#FFADF4"))
                .overlay(Circle().stroke(Color.white, lineWidth: 1))
            isRecording ? Image(systemName: "stop.circle") : Image(systemName: "mic")
            animatedOverlay
        }
        .scaleEffect(isRecording ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isRecording)
    }
}
