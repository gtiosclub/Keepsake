//
//  VoiceRecording.swift
//  KeepsakeWatch Watch App
//
//  Created by Ishita on 2/10/25.
//

import Foundation
import SwiftUI
//
//struct VoiceRecordingView: View {
//    @State private var isRecording = false
//    @State private var elapsedTime: TimeInterval = 0
//    @State private var timer: Timer?
//
//    var formattedTime: String {
//        let minutes = Int(elapsedTime) / 60
//        let seconds = Int(elapsedTime) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all) // Black background like watchOS faces
//            
//            VStack(spacing: 8) {
//                Text(isRecording ? formattedTime : "Tap to Record")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.white)
//                    .monospacedDigit() // Ensures consistent number width
//                
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.2)) {
//                        isRecording.toggle()
//                        if isRecording {
//                            startTimer()
//                        } else {
//                            stopTimer()
//                        }
//                    }
//                }) {
//                    recordingButton
//                }
//                .buttonStyle(PlainButtonStyle()) // Keeps the button clean
//            }
//        }
//    }
//    
//    /// Separated button logic to improve compiler performance
//    private var recordingButton: some View {
//        let baseCircle = Circle()
//            .fill(isRecording ? Color(hex: "#FFADF4").opacity(0.7) : Color(hex: "#FFADF4"))
//            .frame(width: 70, height: 70)
//            .overlay(
//                Circle()
//                    .stroke(Color.white, lineWidth: 1)
//            )
//
//        let animatedOverlay = Circle()
//            .stroke(Color.white.opacity(isRecording ? 0.5 : 0), lineWidth: 5)
//            .scaleEffect(isRecording ? 1.3 : 1.0)
//            .opacity(isRecording ? 0 : 1)
//            .animation(isRecording ? Animation.easeOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isRecording)
//
//        return ZStack {
//            baseCircle
//            animatedOverlay
//        }
//        .scaleEffect(isRecording ? 1.1 : 1.0) // Slightly larger when recording
//        .animation(.easeInOut(duration: 0.2), value: isRecording)
//    }
//
//    private func startTimer() {
//        elapsedTime = 0
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            elapsedTime += 1
//        }
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//}
//
//
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
//
//struct VoiceRecordingView_Previews: PreviewProvider {
//    static var previews: some View {
//        VoiceRecordingView()
//    }
//}

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

//struct DateTimeSelectionView: View {
//    @State private var selectedDate = Date()
//    var recordedAudio: String
//    var onSave: (Reminder) -> Void
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        VStack {
//            Text("Select Reminder Date & Time")
//                .font(.headline)
//            
//            DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
//                .datePickerStyle(WheelDatePickerStyle()) // ✅ Fixed for watchOS
//                .padding()
//            
//            Button(action: {
//                let newReminder = Reminder(title: "Voice Note", date: selectedDate, body: recordedAudio)
//                onSave(newReminder)
//                dismiss()  // Close this view
//            }) {
//                Text("Save Reminder")
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color(hex: "FFADF4"))
//                    .cornerRadius(10)
//            }
//        }
//        .padding()
//    }
//}


struct DateTimeSelectionView: View {
    let recordedAudio: String?  // Or whatever type it is
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
            
            //            Button("Confirm") {
            //                let finalDate = combineDateAndTime()
            //                print("Final Date Selected: \(finalDate)")
            //            }
            Button {
                let finalDate = combineDateAndTime()
                print("Final Date Selected: \(finalDate)")
            } label: {
                Text("Confirm")
            }
            //            Button(action: {
            //                let finalDate = combineDateAndTime()
            //                print("Final Date Selected: \(finalDate)")
            //                        }) {
            //                            Text("Confirm")
            //                        }
            .padding()
        }
    }

    /// 🛠️ Helper function to update date components safely
    private func updateDateComponent(_ component: Calendar.Component, value: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        components.setValue(value, for: component)
        return Calendar.current.date(from: components) ?? selectedDate
    }

    /// 🛠️ Combines the selected date and time into a full Date object
    private func combineDateAndTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = isAM ? (selectedHour == 12 ? 0 : selectedHour) : (selectedHour == 12 ? 12 : selectedHour + 12)
        components.minute = selectedMinute
        return Calendar.current.date(from: components) ?? Date()
    }
}



