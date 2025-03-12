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
    var pageNum: Int
    @ObservedObject var page: JournalPage
    var isDisplay: Bool
    @Binding var inTextEntry: Bool
    @Binding var selectedEntry: Int
    var body: some View {
        let gridItems = [GridItem(.fixed(width), spacing: 10, alignment: .leading),
                         GridItem(.fixed(width), spacing: UIScreen.main.bounds.width * 0.02, alignment: .leading),]

        LazyVGrid(columns: gridItems, spacing: UIScreen.main.bounds.width * 0.02) {
            ForEach(Array(zip(page.entries.indices, page.entries)), id: \.0) { index, widget in
                createView(for: widget, width: width, height: height, isDisplay: isDisplay, inTextEntry: $inTextEntry, selectedEntry: $selectedEntry)
                    .onTapGesture {
                        if widget.type != .image {
                            selectedEntry = index
                            inTextEntry.toggle()
                        }
                    }
                
                
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
func createView(for widget: JournalEntry, width: CGFloat, height: CGFloat, isDisplay: Bool, inTextEntry: Binding<Bool>, selectedEntry: Binding<Int>) -> some View {
    switch widget.type {
    case .written:
        TextEntryView(entry: widget, width: width, height: height).opacity(widget.isFake ? 0 : 1)
    default:
        PictureEntryView(entry: widget, width: width, height: height, isDisplay: isDisplay).opacity(widget.isFake ? 0 : 1)
    }
}

struct PictureEntryView: View {
    var entry: JournalEntry
    var width: CGFloat
    var height: CGFloat
    @State private var timer: Timer?
    @State var selected: Int = 0
    var isDisplay: Bool
    @State var isActive: Bool = true
    var body: some View {
            ZStack {
                // Background Color
                Color.secondary
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .ignoresSafeArea()

                // Carousel
                TabView(selection: $selected) {
                    ForEach(0..<entry.images.count, id: \.self) { index in
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
                                            .fill(Color.white.opacity(selected == dotIndex ? 1 : 0.33))
                                            .frame(width: UIScreen.main.bounds.width * 0.07, height: UIScreen.main.bounds.height * 0.005)
                                            .onTapGesture {
                                                selected = dotIndex
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
            }.frame(height: height, alignment: .top)
            .onAppear {
                isActive = true
                selected = 0
                // Create a new timer instance for each carousel
                timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                    guard isActive else {
                        selected = 0
                        return
                    }
                    
                    selected = (selected + 1) % entry.images.count
                }
            }
            .onDisappear {
                isActive = false
                timer?.invalidate() // Stop the timer when the view disappears
                timer = nil
            }
        }
}

#Preview {
    struct Preview: View {
        @ObservedObject var page: JournalPage = JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1)
        @State var selectedImageIndex: Int = 0
        @State var inTextEntry = false
        @State var selectedEntry: Int = 0
        var body: some View {
            WidgetView(width: UIScreen.main.bounds.width * 0.38, height: UIScreen.main.bounds.height * 0.12, padding: 10, pageNum: 2, page: page, isDisplay: true, inTextEntry: $inTextEntry, selectedEntry: $selectedEntry)
        }
    }

    return Preview()
}

