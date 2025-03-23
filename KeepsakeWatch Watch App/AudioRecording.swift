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
    private var audioPlayer: AVAudioPlayer?
    private var saveFileURL: URL?
    private(set) var isRecording = false
    var recordedAudio: String?
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
            return
        }
        print("Recording started")
        
        // Define the file path where the recording will be saved
        let fileName = UUID().uuidString + ".m4a"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        saveFileURL = fileURL
        print("Recording will be saved at: \(fileURL.path)")
        
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
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        print("Recording stopped")
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
        
        if let fileURL = saveFileURL {
            recordedAudio = fileURL.path
            print("File saved at: \(fileURL.path)")
            playAudio(from: fileURL)
        }
    }
    
    private func playAudio(from url: URL) {
        let session = AVAudioSession.sharedInstance()
        do {
            // Configure the audio session for playback
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set audio session for playback: \(error.localizedDescription)")
        }
        
        do {
            // Now play the audio
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing audio from: \(url.path)")
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
}
