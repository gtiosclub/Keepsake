//
//  JournalPageView.swift
//  Keepsake
//
//  Created by Ganden Fung on 2/17/25.
//


import SwiftUI

// A helper view that splits text into fixed lines and lays them out on fixed-height rows.
struct JournalEntryTextView: View {
    var entry: JournalEntry
    let lineHeight: CGFloat = 18  // Matches the drawn line spacing.
    let maxCharactersPerLine: Int = 30  // Adjust this value as needed.
    
    // Splits a string into an array of lines, trying not to exceed maxCharactersPerLine per line.
    private func splitTextIntoLines(_ text: String) -> [String] {
        var lines: [String] = []
        var currentLine = ""
        let words = text.split(separator: " ")
        
        for word in words {
            if currentLine.isEmpty {
                currentLine = String(word)
            } else if currentLine.count + 1 + word.count <= maxCharactersPerLine {
                currentLine += " " + word
            } else {
                lines.append(currentLine)
                
                if lines.count == 9 { // Stop at 9 lines, append "..." to the last line
                    let truncatedLine = lines.last!.prefix(maxCharactersPerLine - 3) + "..."
                    return Array(lines.prefix(8)) + [String(truncatedLine)]
                }
                
                currentLine = String(word)
            }
        }

        if !currentLine.isEmpty {
            lines.append(currentLine)
        }

        if lines.count > 9 { // Ensure "..." is appended if text is too long
            let truncatedLine = lines[8].prefix(maxCharactersPerLine - 3) + "..."
            return Array(lines.prefix(8)) + [String(truncatedLine)]
        }

        return lines
    }





    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.date)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .frame(height: lineHeight, alignment: .leading)
            
            Text(entry.title)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .frame(height: lineHeight, alignment: .leading)
            
            let lines = splitTextIntoLines(entry.text)
            ForEach(0..<lines.count, id: \.self) { index in
                Text(lines[index])
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(-2.25)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }
}

struct JournalPageView: View {
    @State private var showEntryView = false
    @State private var selectedEntry: JournalEntry? = nil
    @State var book: any Book
    var topEntry: JournalEntry
    var bottomEntry: JournalEntry
    
    // Cache page dimensions for clarity.
    private let pageWidth = UIScreen.main.bounds.width * 0.9
    private let pageHeight = UIScreen.main.bounds.height * 0.55
    
    var body: some View {
        ZStack {
            // Book cover (background shadow)
            RoundedRectangle(cornerRadius: 10)
                .fill(book.template.coverColor)
                .frame(width: pageWidth + 8, height: pageHeight)
                .offset(x: 4, y: 7)
            
            // Page with journal lines.
            RoundedRectangle(cornerRadius: 10)
                .fill(book.template.pageColor)
                .overlay(
                    GeometryReader { geo in
                        let lineSpacing: CGFloat = 20
                        // Leave a top margin of 20.
                        let numberOfLines = Int((geo.size.height - 20) / lineSpacing)
                        
                        ForEach(0..<numberOfLines, id: \.self) { index in
                            let yPosition = CGFloat(index + 1) * lineSpacing
                            Path { path in
                                path.move(to: CGPoint(x: 10, y: yPosition))
                                path.addLine(to: CGPoint(x: geo.size.width - 10, y: yPosition))
                            }
                            .stroke(Color.black.opacity(0.7), lineWidth: 1)
                        }
                    }
                )
                .frame(width: pageWidth, height: pageHeight)
                .offset(x: 5, y: 5)
            
            VStack(spacing: 0) {
                Button(action: {
                    selectedEntry = topEntry
                    showEntryView = true
                }) {
                    JournalEntryTextView(entry: topEntry)
                        .frame(height: UIScreen.main.bounds.height / 2, alignment: .top)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    selectedEntry = bottomEntry
                    showEntryView = true
                }) {
                    JournalEntryTextView(entry: bottomEntry)
                        .frame(height: UIScreen.main.bounds.height / 2, alignment: .top)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height)
            .offset(x: 5, y: 5)
            .sheet(isPresented: $showEntryView) {
                if let entry = selectedEntry {
                    JournalEntryView(entry: entry)
                        .presentationDetents([.medium, .large]) // Allows resizing
                        .presentationDragIndicator(.visible) // Swipe down to dismiss
                }
            }
        }
    }   
}


#Preview {
    // Create a sample book and two sample journal entries.
    JournalPageView(
        book: Journal(
            name: "Journal 1",
            createdDate: "2/2/25",
            entries: [],
            category: "entry1",
            isSaved: true,
            isShared: false,
            template: Template(coverColor: .red, pageColor: .white, titleColor: .black)
        ),
        topEntry: JournalEntry(
            date: "Feb 21, 2025",
            title: "Morning Thoughts",
            text: "Today was one of those rare, peaceful days where everything seemed to slow down. I woke up to the sound of light rain tapping against the window, a comforting rhythm that made me linger in bed a little longer. Breakfast was simple—just a warm cup of tea and toast—but it felt like a luxury to eat without rushing. I spent most of the afternoon reading, getting lost in a novel that had been sitting on my shelf for months. The words pulled me in, and for a while, the outside world faded away. By evening, the sky had cleared, so I went for a walk. The air was crisp, and the streets were quiet, except for the occasional rustle of leaves. It felt good to just breathe, to exist in the moment without any distractions. Some days don’t need to be extraordinary to be meaningful."
        ),
        bottomEntry: JournalEntry(
            date: "Feb 15, 2025",
            title: "Evening Reflections",
            text: "Spent time reading a book and reflecting on the day's events."
        )
    )
}
