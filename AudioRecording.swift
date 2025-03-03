//
//  AudioRecording.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/3/25.
//

import Foundation
import AVFoundation

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
//        let fileName = UUID().uuidString + ".m4a"
////        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileURL = documentsDirectory.appendingPathComponent(fileName)
//        let fileName = UUID().uuidString + ".m4a"
//        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
//        let fileURL = downloadsDirectory.appendingPathComponent(fileName)
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
        
        if let fileURL = saveFileURL {
            playAudio(from: fileURL)
        }
        
    }
    private func playAudio(from url: URL) {
        let player = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: player)
        audioPlayer?.play()
        print(url)
    }
}
