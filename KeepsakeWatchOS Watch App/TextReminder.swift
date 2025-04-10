//
//  TextReminder.swift
//  Keepsake
//
//  Created by Nitya Potti on 3/29/25.
//
import SwiftUI

struct TextReminder: View {
    @EnvironmentObject var viewModel: RemindersViewModel
    @State private var selectedDate = Date()
    @State private var selectedHour = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute = Calendar.current.component(.minute, from: Date())
    @State private var isAM = Calendar.current.component(.hour, from: Date()) < 12
    @State private var reminderText = ""

    var body: some View {
        VStack {
            HStack {
                Picker("Month", selection: Binding(
                    get: { Calendar.current.component(.month, from: selectedDate) },
                    set: { month in selectedDate = updateDateComponent(.month, value: month) }
                )) {
                    ForEach(1...12, id: \.self ) { month in
                        Text(Calendar.current.shortMonthSymbols[month - 1]).tag(month)
                    }
                }.pickerStyle(WheelPickerStyle()).frame(width: 60, height: 40)
                
                Picker("Day", selection: Binding(
                    get: { Calendar.current.component(.day, from: selectedDate) },
                    set: { day in selectedDate = updateDateComponent(.day, value: day) }
                )) {
                    ForEach(1...31, id: \.self ) { day in
                        Text("\(day)").tag(day)
                    }
                }.pickerStyle(WheelPickerStyle()).frame(width: 60, height: 40)
                
                Picker("Year", selection: Binding(
                    get: { Calendar.current.component(.year, from: selectedDate) },
                    set: { year in selectedDate = updateDateComponent(.year, value: year) }
                )) {
                    ForEach(2024...2035, id: \.self ) { year in
                        Text("\(year)").tag(year)
                    }
                }.pickerStyle(WheelPickerStyle()).frame(width: 60, height: 40)
            }

            HStack {
                Picker("Hour", selection: $selectedHour) {
                    ForEach(1...12, id: \.self ) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }.pickerStyle(WheelPickerStyle()).frame(width: 60, height: 40)
                
                Picker("Minute", selection: $selectedMinute) {
                    ForEach(0..<60, id: \.self ) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }.pickerStyle(WheelPickerStyle()).frame(width: 60, height: 40)
                
                Picker("AM/PM", selection: $isAM) {
                    Text("AM").tag(true)
                    Text("PM").tag(false)
                }.pickerStyle(WheelPickerStyle()).frame(width: 60, height: 40)
            }

            TextField("Enter Reminder Text", text: $reminderText)
//            Button("Confirm") {
//                let finalDate = combineDateAndTime()
//                let reminder = Reminder(title: reminderText, date: finalDate, body: reminderText)
//                viewModel.addReminder(reminder)
//            }
        }
        .padding()
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
