//
//  WidgetView.swift
//  Keepsake
//
//  Created by Alec Hance on 3/6/25.
//

import SwiftUI

struct WidgetView: View {
    var width: CGFloat
    var height: CGFloat
    var padding: CGFloat
    var entries: [JournalEntry]
    var body: some View {
        let gridItems = [GridItem(.fixed(width), spacing: 10, alignment: .leading),
                         GridItem(.fixed(width), spacing: UIScreen.main.bounds.width * 0.02, alignment: .leading),]

        LazyVGrid(columns: gridItems, spacing: UIScreen.main.bounds.width * 0.02) {
            ForEach(Array(zip(entries.indices, entries)), id: \.0) { index, widget in
                createView(for: widget, width: width, height: height)
                
                
            }
        }
        .frame(width: 470)
    }
}

struct TextEntryView: View {
    var entry: JournalEntry
    var width: CGFloat
    var height: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black)
                .fill(Color(red: entry.color[0], green: entry.color[1], blue: entry.color[2]))
                .frame(width: entry.frameWidth, height: entry.frameHeight)
                .opacity(entry.isFake ? 0 : 1)
                .frame(height: height, alignment: .top)
            VStack {
                Text(entry.title)
                    .frame(width: entry.frameWidth - 10)
                    .scaledToFill()
                    .lineLimit(2)
                Text(entry.date)
                    .frame(width: entry.frameWidth - 10)
                    .scaledToFill()
                    .lineLimit(1)
                if entry.width == 2 && entry.height == 2 {
                    Text(entry.summary)
                        .frame(width: entry.frameWidth - 10)
                        .scaledToFill()
                        .lineLimit(1)
                }
            }.padding(.horizontal, 10)
        }
    }
}

@ViewBuilder
func createView(for widget: JournalEntry, width: CGFloat, height: CGFloat) -> some View {
    switch widget.type {
    case .written:
        TextEntryView(entry: widget, width: width, height: height).opacity(widget.isFake ? 0 : 1)
    default:
        PictureEntryView(entry: widget, width: width, height: height).opacity(widget.isFake ? 0 : 1)
    }
}

struct PictureEntryView: View {
    var entry: JournalEntry
    var width: CGFloat
    var height: CGFloat
    let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    @State var selectedImageIndex: Int = 0
    var body: some View {
            ZStack {
                // Background Color
                Color.secondary
                    .ignoresSafeArea()

                // Carousel
                TabView(selection: $selectedImageIndex) {
                    ForEach(entry.images.indices, id: \.self) { index in
                        ZStack {
                            if let uiImage = UIImage(data: entry.images[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: entry.frameWidth, height: entry.frameHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .tag(index)
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 350, height: 200)
                                    .tag(index)
                            }

                            // Navigation Dots (Stacked on top of images)
                            VStack {
                                Spacer()
                                Spacer()
                                Spacer()
                                HStack {
                                    ForEach(entry.images.indices, id: \.self) { dotIndex in
                                        Capsule()
                                            .fill(Color.white.opacity(selectedImageIndex == dotIndex ? 1 : 0.33))
                                            .frame(width: 35, height: 8)
                                            .onTapGesture {
                                                selectedImageIndex = dotIndex
                                            }
                                    }
                                }
                                
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3)))
                                 // Adjust dot position
                                Spacer()
                            }.frame(width: entry.frameWidth, height: entry.frameHeight)
                        }
                    }
                }
                .frame(width: entry.frameWidth, height: entry.frameHeight)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hides default dots
                .ignoresSafeArea()
            }.frame(width: entry.frameWidth, height: entry.frameHeight)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut) {
                    selectedImageIndex = (selectedImageIndex + 1) % entry.images.count
                }
            }
        }
}

#Preview {
    WidgetView(width: UIScreen.main.bounds.width * 0.38, height: UIScreen.main.bounds.height * 0.12, padding: UIScreen.main.bounds.width * 0.02, entries: [
        JournalEntry(date: "01/01/2000", title: "Entry Title", text: "Entry Text", summary: "Summary Text", width: 1, height: 1, isFake: false, color: [0.5,0.5,0.5]),
        JournalEntry(date: "01/01/2000", title: "Entry Title", text: "Entry Text", summary: "Summary Text", width: 1, height: 1, isFake: false, color: [0.5,0.5,0.5]),
        JournalEntry(date: "01/01/2000", title: "Entry Title", text: "Entry Text", summary: "Summary Text", width: 2, height: 1, isFake: false, color: [0.5,0.5,0.5]),
        JournalEntry(date: "01/01/2000", title: "Entry Title", text: "Entry Text", summary: "Summary Text", width: 1, height: 1, isFake: true, color: [0.5,0.5,0.5]),
        JournalEntry(date: "01/01/2000", title: "Entry Title", text: "Entry Text", summary: "Summary Text", width: 1, height: 1, isFake: false, color: [0.5,0.5,0.5]),
        JournalEntry(date: "01/01/2000", title: "Entry Title", text: "Entry Text", summary: "Summary Text", width: 1, height: 2, isFake: false, color: [0.5,0.5,0.5]),
        JournalEntry(date: "01/01/2000", title: "Entry Title", text: "Entry Text", summary: "Summary Text", width: 1, height: 1, isFake: false, color: [0.5,0.5,0.5]),
        JournalEntry(date: "01/01/2000", title: "Entry Title", text: "Entry Text", summary: "Summary Text", width: 1, height: 1, isFake: true, color: [0.5,0.5,0.5]),
        JournalEntry(date: "01/01/2000", title: "Entry Title", text: "Entry Text", summary: "Summary Text", width: 2, height: 2, isFake: false, color: [0.5,0.5,0.5]),
    ])
}
