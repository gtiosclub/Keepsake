//
//  VoiceRecording.swift
//  KeepsakeWatch Watch App
//
//  Created by Ishita on 2/10/25.
//

import Foundation
import SwiftUI

struct VoiceRecordingView: View {
    @State private var isRecording = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

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
                        if isRecording {
                            startTimer()
                        } else {
                            stopTimer()
                        }
                    }
                }) {
                    Circle()
                        .fill(isRecording ? Color.red.opacity(0.7) : Color.red) // Darker red when recording
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .scaleEffect(isRecording ? 1.1 : 1.0) // Slightly larger when recording
                        .animation(.easeInOut(duration: 0.2), value: isRecording)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(isRecording ? 0.5 : 0), lineWidth: 5)
                                .scaleEffect(isRecording ? 1.3 : 1.0)
                                .opacity(isRecording ? 0 : 1)
                                .animation(isRecording ? Animation.easeOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isRecording)
                        )
                }
                .buttonStyle(PlainButtonStyle()) // Keeps the button clean
            }
        }
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

struct VoiceRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecordingView()
    }
}

