//
//  AudioFiles.swift
//  Keepsake
//
//  Created by Nitya Potti on 3/30/25.
//
import SwiftUI

struct AudioFilesView: View {
    @State private var remindersWithAudio: [(reminder: Reminder, audioUrl: String)] = []
    @State private var isChecked: Bool = false
    var body: some View {
        VStack {
            if remindersWithAudio.isEmpty {
                Text("No audio files found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(remindersWithAudio, id: \.audioUrl) { reminderWithAudio in
                        Button(action: {
                            playAudio(from: reminderWithAudio.audioUrl)
                        }) {
                            HStack {
                                Button(action: {
                                    isChecked.toggle()
                                    Connectivity.shared.updateIsCheckedInFirestore(reminderId: reminderWithAudio.audioUrl, isChecked: isChecked)
                                }) {
                                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isChecked ? Color.pink : Color.gray)
                                        .font(.title2)
                                }

                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(Color(hex: "FFADF4"))
                                    .font(.title2)

                                VStack(alignment: .leading) {
                                    Text("Audio Recording")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    // Display reminder date
                                    Text("Reminder Date: \(reminderWithAudio.reminder.date, style: .date)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchAllAudioFiles()
        }
    }

    func fetchAllAudioFiles() {
        #if os(iOS)
        Task {
            await Connectivity.shared.fetchAudioFiles()
            remindersWithAudio = Connectivity.shared.remindersWithAudio
        }
        #endif
        #if os(watchOS)
        Connectivity.shared.requestAudioFiles()
        #endif
    }
}


import AVFoundation
#if os(iOS)
import AVKit
import FirebaseCore
#endif

var audioPlayer: AVPlayer?
func playAudio(from url: String) {
    guard let audioURL = URL(string: url) else {
        print("invalid audio url: \(url)")
        return
    }

    #if os(iOS)
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback)
        try AVAudioSession.sharedInstance().setActive(true)
        audioPlayer = AVPlayer(url: audioURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = audioPlayer
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(playerViewController, animated: true) {
                audioPlayer?.play()
            }
        } else {
            print("Could not find root view controller")
        }
    } catch {
        print("Error setting up audio session: \(error.localizedDescription)")
    }
    #endif

    #if os(watchOS)
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback)
        try AVAudioSession.sharedInstance().setActive(true)
        
        audioPlayer = AVPlayer(url: audioURL)
        audioPlayer?.play()
    } catch {
        print("Error setting up audio session: \(error.localizedDescription)")
    }
    #endif
}
