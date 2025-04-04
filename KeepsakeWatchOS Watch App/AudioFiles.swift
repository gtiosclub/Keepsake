//
//  AudioFiles.swift
//  Keepsake
//
//  Created by Nitya Potti on 3/30/25.
//
import SwiftUI
struct AudioFilesView: View {
    
    
    var body: some View {
        VStack {
            if Connectivity.shared.audioFiles.isEmpty {
                Text("No audio files found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(Connectivity.shared.audioFiles, id: \.self) { audioURL in
                        Button(action: {
                            playAudio(from: audioURL)
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(Color(hex: "FFADF4"))
                                    .font(.title2)
                                
                                Text("Audio Recording \(Connectivity.shared.audioFiles.firstIndex(of: audioURL)! + 1)")
                                    .foregroundColor(.primary)
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
        Task {
            await Connectivity.shared.fetchAudioFiles()
        }
        
    }
}


import AVFoundation
#if os(iOS)
import AVKit
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
