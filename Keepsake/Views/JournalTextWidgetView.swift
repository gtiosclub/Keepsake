//
//  JournalTextWidgetView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/27/25.
//

import SwiftUI

struct JournalTextWidgetView: View {
    @State var entry: JournalEntry
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.black)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.15)
                VStack {
                    Text(entry.title)
                        .font(.headline)
                    Text(entry.date)
                        .font(.subheadline)
                    Rectangle()
                        .opacity(0)
                        .overlay{
                            Text("Summary: \(entry.summary)")
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }.padding(.leading, 10)
                    Spacer()
                }.frame(maxWidth: .infinity).padding(.vertical, 5)
            }.frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.15)
        }.frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.15)
    }
}

#Preview {
    JournalTextWidgetView(entry: JournalEntry(date: "01-01-2025", title: "Daily Reflection", text: "Text that could be very long", summary: "I had a great day, asdfasdfasda, asdfalsdfsad, asdfajsdfl, adsflkasdjflsk"))
}
