//
//  JournalTextWidgetView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/27/25.
//

import SwiftUI

struct JournalTextWidgetView: View {
    @Binding var entry: JournalEntry
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.black)
                    .fill(Color.white)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.15)
                VStack {
                    Text(entry.title)
                        .font(.headline)
                        .padding(.horizontal, 10)
                    Text(entry.date)
                        .font(.subheadline)
                    Rectangle()
                        .opacity(0)
                        .overlay{
                            Text("\(entry.summary)")
                                .italic()
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .fixedSize(horizontal: false, vertical: true)
                        }.padding(.leading, 10)
                        .padding(.trailing, 2)
                    Spacer()
                }.frame(maxWidth: .infinity).padding(.vertical, 5)
            }.frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.15)
        }.frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.15)
    }
}

#Preview {
    struct Preview: View {
        @State var entry = JournalEntry(date: "01/01/2000", title: "Title", text: "written text", summary: "recipe for great protein shake")
        var body: some View {
            JournalTextWidgetView(entry: $entry)
        }
    }

    return Preview()
}
