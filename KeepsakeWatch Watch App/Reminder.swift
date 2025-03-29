//
//  Reminder.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/29/25.
//

import Foundation
import SwiftUI
//
//// Reminder Model
struct Reminder: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var body: String
}
//extension Color {
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
struct RemindersListView: View {
@EnvironmentObject private var viewModel: RemindersViewModel

var body: some View {

    
    NavigationStack {
        VStack {
            ForEach(viewModel.reminders) { reminder in
                VStack(alignment: .leading) {
                    Text(reminder.title)
                        .font(.headline)
                    Text(reminder.date, style: .date)
                        .font(.subheadline)
                    Text(reminder.body)
                        .font(.body)
                }
                .padding(.vertical, 5)
            }
            #if os(iOS)
            NavigationLink(
                destination: TextReminder()
                    .environmentObject(viewModel),
                label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "FFADF4"))
                        .font(.title)
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.3)))
                        .shadow(radius: 10)
                }
            )
            .buttonStyle(PlainButtonStyle()) // To remove default button style
            #endif
            #if os(watchOS)
            NavigationLink(
                destination: Choice()
                    .environmentObject(viewModel),
                label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "FFADF4"))
                        .font(.title)
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.3)))
                        .shadow(radius: 10)
                }
            )
            .buttonStyle(PlainButtonStyle()) // To remove default button style
            #endif
        }
    }
}
}
