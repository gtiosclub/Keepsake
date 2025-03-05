//
//  TextReminder.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/5/25.
//

import SwiftUI

struct TextReminder: View {
    
    var onComplete: (Reminder) -> Void
    @State private var selectedDate = Date()
    @State private var selectedHour = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute = Calendar.current.component(.minute, from: Date())
    @State private var isAM = Calendar.current.component(.hour, from: Date()) < 12
    @State var reminderText: String = ""

    var body: some View {
        ScrollView {
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
                        .frame(width: 60)
                    
                    
                    Picker("Day", selection: Binding(
                        get: { Calendar.current.component(.day, from: selectedDate) },
                        set: { day in selectedDate = updateDateComponent(.day, value: day) }
                    )) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }.pickerStyle(WheelPickerStyle())
                        .frame(width: 60)
                    
                    Picker("Year", selection: Binding(
                        get: { Calendar.current.component(.year, from: selectedDate) },
                        set: { year in selectedDate = updateDateComponent(.year, value: year) }
                    )) {
                        ForEach(2024...2035, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }.pickerStyle(WheelPickerStyle())
                        .frame(width: 60, height: 40)
                    
                }
                
                // Time Selection: Hour, Minute, AM/PM
                HStack {
                    Picker("Hour", selection: $selectedHour) {
                        ForEach(1...12, id: \.self) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }.pickerStyle(WheelPickerStyle())
                        .frame(width: 60, height: 40)
                    
                    Picker("Minute", selection: $selectedMinute) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }.pickerStyle(WheelPickerStyle())
                        .frame(width: 60, height: 40)
                    
                    Picker("AM/PM", selection: $isAM) {
                        Text("AM").tag(true)
                        Text("PM").tag(false)
                    }.pickerStyle(WheelPickerStyle())
                        .frame(width: 60, height: 40)
                }
            }
                TextField("Enter Reminder Text", text: $reminderText)
                Button {
                    let finalDate = combineDateAndTime()
                    
                    // Create a dictionary with the reminder details
                    
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .long
                    formatter.timeStyle = .long
                    formatter.timeZone = TimeZone.current
                    print("Final Date Selected: (\(formatter.string(from: finalDate))")
                    
                    
                } label: {
                    Text("Confirm")
                        .cornerRadius(25)
                }
                
                
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
        if isAM {
            components.hour = (selectedHour == 12) ? 0 : selectedHour
        } else {
            components.hour = (selectedHour == 12) ? 12 : selectedHour + 12
        }
       
        components.minute = selectedMinute
        return Calendar.current.date(from: components) ?? Date()
    }
}

