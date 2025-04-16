//
//  JournalTextWidgetView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/27/25.
//

import SwiftUI

struct JournalTextWidgetView: View {
    var entry: JournalEntry
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(colors: [
                    Color(red: entry.color[0], green: entry.color[1], blue: entry.color[2]).opacity(0.9),
                    Color(red: entry.color[0] * 0.8, green: entry.color[1] * 0.8, blue: entry.color[2] * 0.8)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.15)
                .opacity(entry.isFake ? 0 : 1)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
            VStack {
                Text(entry.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .scaledToFill()
                    .lineLimit(2)
                Text(entry.date)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .scaledToFill()
                    .lineLimit(2)
            }
        }.frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.15)

    }
}

#Preview {
    struct Preview: View {
        @State var entry = WrittenEntry(date: "01/01/2000", title: "Title", text: "written text", summary: "recipe for great protein shake")
        var body: some View {
            JournalTextWidgetView(entry: entry)
        }
    }

    return Preview()
}
