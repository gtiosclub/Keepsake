//
//  JournalVoiceMemoInputView.swift
//  Keepsake
//
//  Created by Holden Casey on 3/12/25.
//

import SwiftUI
import Foundation
import AVFoundation

struct JournalVoiceMemoInputView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var aiVM: AIViewModel
    var shelfIndex: Int
    var journalIndex: Int
    var entryIndex: Int
    var pageIndex: Int
    @State var title: String = ""
    @State var date: String = ""
    @State var audioRecording: AudioRecording = AudioRecording()
    @State var transcription: String = ""
    var entry: JournalEntry
    @State var showPromptSheet: Bool = false
    @State var selectedPrompt: String? = ""
    var body: some View {
        VoiceRecordingView(audioRecording: audioRecording)
            .frame(width: UIScreen.main.bounds.width / 5)
            .font(.title)
            
    }
}

#Preview {
    JournalVoiceMemoInputView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
        Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
        Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
        Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
    ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), aiVM: AIViewModel(), shelfIndex: 0, journalIndex: 0, entryIndex: 0, pageIndex: 2, entry: JournalEntry(date: "01/02/2024", title: "Oh my world", text: "I have started to text", summary: "summary"), selectedPrompt: "Summarize the highlights of your day and any moments of learning")
}

final class AudioRecording {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVPlayer?
    private var saveFileURL: URL?
    private(set) var isRecording = false
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
        } catch {
            print("failed")
        }
        print("recording started")
        let fileName = UUID().uuidString + ".m4a"
        let downloadsDirectory = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Downloads")
        let fileURL = downloadsDirectory.appendingPathComponent(fileName)

        saveFileURL = fileURL
        saveFileURL = fileURL
        print(fileName)
        print(fileURL.path)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("fail")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        print("recording ended")
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            print("failed")
        }
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

struct VoiceRecordingView: View {
    @State private var isRecording = false
    var audioRecording: AudioRecording

    @State private var recordedAudio: String? // Placeholder for recorded file name

    @Environment(\.dismiss) private var dismiss  // Dismiss when done

    var body: some View {
        VStack(spacing: 8) {
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
        }
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
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                )
            isRecording ? Image(systemName: "stop.circle") : Image(systemName: "mic")
            animatedOverlay
        }
        .scaleEffect(isRecording ? 1.1 : 1.0) // Slightly larger when recording
        .animation(.easeInOut(duration: 0.2), value: isRecording)

    }
}

