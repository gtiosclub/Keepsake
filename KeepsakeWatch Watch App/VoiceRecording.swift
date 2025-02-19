//
//  VoiceRecording.swift
//  KeepsakeWatch Watch App
//
//  Created by Ishita on 2/10/25.
//

import Foundation
import SwiftUI
import AVFoundation

struct VoiceRecordingView: View {
//    @ObservedObject private var audioRecorder = AudioRecorder()
    @State private var isRecording = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    private let audioRecording = AudioRecording()

    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Black background like watchOS faces
            
            VStack(spacing: 8) {
                Text(isRecording ? formattedTime : "Tap to Record")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .monospacedDigit() // Ensures consistent number width
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRecording.toggle()
                        if audioRecording.isRecording {
                            audioRecording.stopRecording()
                            stopTimer()
                        } else {
                            audioRecording.startRecording()
                            startTimer()
                        }
                    }
                }) {
                    recordingButton
                }
                .buttonStyle(PlainButtonStyle()) // Keeps the button clean
            }
        }
    }
    
    /// Separated button logic to improve compiler performance
    private var recordingButton: some View {
        let baseCircle = Circle()
            .fill(isRecording ? Color(hex: "#FFADF4").opacity(0.7) : Color(hex: "#FFADF4"))
            .frame(width: 70, height: 70)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 1)
            )

        let animatedOverlay = Circle()
            .stroke(Color.white.opacity(audioRecording.isRecording ? 0.5 : 0), lineWidth: 5)
            .scaleEffect(isRecording ? 1.3 : 1.0)
            .opacity(isRecording ? 0 : 1)
            .animation(isRecording ? Animation.easeOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isRecording)

        return ZStack {
            baseCircle
            animatedOverlay
        }
        .scaleEffect(isRecording ? 1.1 : 1.0) // Slightly larger when recording
        .animation(.easeInOut(duration: 0.2), value: isRecording)
    }

    private func startTimer() {
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
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

struct VoiceRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecordingView()
    }
}

