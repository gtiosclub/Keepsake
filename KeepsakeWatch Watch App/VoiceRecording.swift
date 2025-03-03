//
//  VoiceRecording.swift
//  KeepsakeWatch Watch App
//
//  Created by Ishita on 2/10/25.
//

import Foundation
import SwiftUI

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
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showDateTimeSelection = false
    @State private var recordedAudio: String? // Placeholder for recorded file name

    var onRecordingComplete: (Reminder) -> Void
    @Environment(\.dismiss) private var dismiss  // Dismiss when done

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 8) {
                Text(isRecording ? formattedTime : "Tap to Record")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRecording.toggle()
                        if isRecording {
                            startTimer()
                        } else {
                            stopTimer()
                            recordedAudio = "AudioFile123.m4a" // Simulate recorded file name
                            showDateTimeSelection = true  // Show date picker
                        }
                    }
                }) {
                    recordingButton
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .fullScreenCover(isPresented: $showDateTimeSelection) {
            if let recordedAudio = recordedAudio {
                DateTimeSelectionView(recordedAudio: recordedAudio) { newReminder in
                    onRecordingComplete(newReminder)
                    dismiss() // Close everything
                }
            }
        }
    }
    
    private var recordingButton: some View {
        Circle()
            .fill(isRecording ? Color(hex: "FFADF4").opacity(0.7) : Color(hex: "FFADF4"))
            .frame(width: 70, height: 70)
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
            .scaleEffect(isRecording ? 1.1 : 1.0)
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

    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct DateTimeSelectionView: View {
    let recordedAudio: String?  // Placeholder for the recorded file data
    var onComplete: (Reminder) -> Void
    @State private var selectedDate = Date()
    @State private var selectedHour = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute = Calendar.current.component(.minute, from: Date())
    @State private var isAM = Calendar.current.component(.hour, from: Date()) < 12

    var body: some View {
        VStack {
            // Date Selection: Month, Day, Year
            HStack {
                Picker("Month", selection: Binding(
                    get: { Calendar.current.component(.month, from: selectedDate) },
                    set: { month in selectedDate = updateDateComponent(.month, value: month) }
                )) {
                    ForEach(1...12, id: \.self) { month in
                        Text(Calendar.current.shortMonthSymbols[month - 1]).tag(month)
                    }
                }.pickerStyle(WheelPickerStyle())
                
                Picker("Day", selection: Binding(
                    get: { Calendar.current.component(.day, from: selectedDate) },
                    set: { day in selectedDate = updateDateComponent(.day, value: day) }
                )) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)").tag(day)
                    }
                }.pickerStyle(WheelPickerStyle())
                
                Picker("Year", selection: Binding(
                    get: { Calendar.current.component(.year, from: selectedDate) },
                    set: { year in selectedDate = updateDateComponent(.year, value: year) }
                )) {
                    ForEach(2024...2035, id: \.self) { year in
                        Text("\(year)").tag(year)
                    }
                }.pickerStyle(WheelPickerStyle())
            }
            
            // Time Selection: Hour, Minute, AM/PM
            HStack {
                Picker("Hour", selection: $selectedHour) {
                    ForEach(1...12, id: \.self) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }.pickerStyle(WheelPickerStyle())
                
                Picker("Minute", selection: $selectedMinute) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }.pickerStyle(WheelPickerStyle())
                
                Picker("AM/PM", selection: $isAM) {
                    Text("AM").tag(true)
                    Text("PM").tag(false)
                }.pickerStyle(WheelPickerStyle())
            }
            
            Button {
                let finalDate = combineDateAndTime()
                
                // Automatically generate the title for the reminder
                let title = "Reminder for \(finalDate.formatted(date: .abbreviated, time: .shortened))"
                
                let reminder = Reminder(title: title, date: finalDate, body: recordedAudio ?? "")
                onComplete(reminder)
            } label: {
                Text("Confirm")
            }
            .padding()
        }
    }

    private func updateDateComponent(_ component: Calendar.Component, value: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        components.setValue(value, for: component)
        return Calendar.current.date(from: components) ?? selectedDate
    }

    private func combineDateAndTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        if isAM {
            components.hour = (selectedHour == 12) ? 0 : selectedHour
        } else {
            components.hour = (selectedHour == 12) ? 12 : selectedHour + 12
        }
       
        components.minute = selectedMinute
        return Calendar.current.date(from: components) ?? Date()
    }
}




