//
//  WidgetView.swift
//  Keepsake
//
//  Created by Alec Hance on 3/6/25.
//

import SwiftUI
import PhotosUI

enum EntrySize {
    case small, medium, large
}
struct WidgetView: View {
    var width: CGFloat
    var height: CGFloat
    var padding: CGFloat
    var pageNum: Int
    @ObservedObject var page: JournalPage
    var isDisplay: Bool
    @Binding var inEntry: EntryType
    @Binding var selectedEntry: Int
    @ObservedObject var userVM: UserViewModel
    @Binding var showDeleteButton: Int
    @State private var isWiggling = false // Control wiggle animation
    @ObservedObject var journal: Journal
    @ObservedObject var fbVM: FirebaseViewModel
    @Binding var frontDegrees: CGFloat
    var body: some View {
        let gridItems = [GridItem(.fixed(width), spacing: 10, alignment: .leading),
                         GridItem(.fixed(width), spacing: UIScreen.main.bounds.width * 0.02, alignment: .leading),]

        LazyVGrid(columns: gridItems, spacing: UIScreen.main.bounds.width * 0.02) {
            ForEach(Array(zip(page.entries.indices, page.entries)), id: \.0) { index, widget in
                ZStack(alignment: .topLeading) {
                    createView(for: widget, width: width, height: height, isDisplay: isDisplay, inEntry: $inEntry, selectedEntry: $selectedEntry, fbVM: fbVM, journal: journal, userVM: userVM, pageNum: pageNum, entryIndex: index, frontDegrees: $frontDegrees, showDeleteButton: $showDeleteButton, isWiggling: $isWiggling)
                        .onTapGesture {
                            if showDeleteButton != -1 {
                                showDeleteButton = -1
                                isWiggling = false
                            } else if widget.type == .written {
                                selectedEntry = index
                                inEntry = .written
                            } else if widget.type == .voice {
                                selectedEntry = index
                                inEntry = .voice
                            } else if widget.type == .chat {
                                selectedEntry = index
                                inEntry = .chat
                            }
                        }
                        .onLongPressGesture {
                            withAnimation {
                                showDeleteButton = index
                                isWiggling = true
                            }
                        }

                    // Always keep the button in the view, but control visibility with opacity
                    Button {
                        let entryID = page.entries[index].id
                        userVM.removeJournalEntry(page: page, index: index)
                        Task {
                            await fbVM.removeJournalEntry(entryID: entryID)
                            await fbVM.updateJournalPage(entries: page.entries, journalID: journal.id, pageNumber: pageNum)
                        }
                        withAnimation {
                            showDeleteButton = -1
                            isWiggling = false
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 25, height: 25)
                            Image(systemName: "minus")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .opacity(showDeleteButton == index ? 1 : 0) // Instead of removing the button, fade it in/out
                    .animation(.easeInOut(duration: 0.2), value: showDeleteButton) // Smooth fade effect
                    .offset(x: -10, y: -10)

                }
                .rotationEffect(.degrees(isWiggling && showDeleteButton == index ? 2 : 0)) // Wiggle effect
                .animation(isWiggling && showDeleteButton == index ?
                           Animation.easeInOut(duration: 0.1).repeatForever(autoreverses: true)
                           : .default, value: isWiggling)
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
                .fill(LinearGradient(colors: [
                                    Color(red: entry.color[0], green: entry.color[1], blue: entry.color[2]).opacity(0.9),
                                    Color(red: entry.color[0] * 0.8, green: entry.color[1] * 0.8, blue: entry.color[2] * 0.8)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: width * CGFloat(entry.width) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.width - 1), height: height * CGFloat(entry.height) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.height - 1))
                .opacity(entry.isFake ? 0 : 1)
                .frame(height: height, alignment: .top)
            VStack {
                Text(entry.title)
                    .frame(width: width * CGFloat(entry.width) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.width - 1) - 10)
                    .scaledToFill()
                    .lineLimit(2)
                Text(entry.date)
                    .frame(width: width * CGFloat(entry.width) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.width - 1) - 10)
                    .scaledToFill()
                    .lineLimit(1)
                if entry.width == 2 && entry.height == 2 {
                    Text(entry.summary)
                        .frame(width: width * CGFloat(entry.width) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.width - 1) - 10)
                        .scaledToFill()
                        .lineLimit(1)
                }
            }
        }
    }
}

//
@ViewBuilder
func createView(for widget: JournalEntry, width: CGFloat, height: CGFloat, isDisplay: Bool, inEntry: Binding<EntryType>, selectedEntry: Binding<Int>, fbVM: FirebaseViewModel, journal: Journal, userVM: UserViewModel, pageNum: Int, entryIndex: Int, frontDegrees: Binding<CGFloat>, showDeleteButton: Binding<Int>, isWiggling: Binding<Bool>) -> some View {
    switch widget.type {
    case .image:
        PictureEntryView(entry: widget, width: width, height: height, isDisplay: isDisplay, fbVM: fbVM, journal: journal, userVM: userVM, pageNum: pageNum, entryIndex: entryIndex, frontDegrees: frontDegrees, showDeleteButton: showDeleteButton, isWiggling: isWiggling).opacity(widget.isFake ? 0 : 1)
    default:
        TextEntryView(entry: widget, width: width, height: height).opacity(widget.isFake ? 0 : 1)
    }
}

struct PictureEntryView: View {
    var entry: JournalEntry
    var width: CGFloat
    var height: CGFloat
    @State private var timer: Timer?
    @State var selected: Int = 0
    var isDisplay: Bool
    @State var isActive: Bool = false
    @State var uiImages: [UIImage] = []
    @ObservedObject var fbVM: FirebaseViewModel
    @State var selectedItems = [PhotosPickerItem]()
    @State var selectedImages = [UIImage]()
    @State var imageURLs: [String] = []
    @ObservedObject var journal: Journal
    @ObservedObject var userVM: UserViewModel
    @State var pageNum: Int
    @State var entryIndex: Int
    @State var isPickerPresented: Bool = false
    @Binding var frontDegrees: CGFloat
    @Binding var showDeleteButton: Int
    @Binding var isWiggling: Bool
    var body: some View {
            ZStack {
                // Background Color
                Color.secondary
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .ignoresSafeArea()

                if uiImages.count != 0 {
                    TabView(selection: $selected) {
                        ForEach(0..<uiImages.count, id: \.self) { index in
                            ZStack {
                                Image(uiImage: uiImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: width * CGFloat(entry.width) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.width - 1), height: height * CGFloat(entry.height) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.height - 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .tag(index)
                                
                                // Navigation Dots (Stacked on top of images)
                                VStack {
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    HStack {
                                        ForEach(uiImages.indices, id: \.self) { dotIndex in
                                            Capsule()
                                                .fill(Color.white.opacity(selected == dotIndex ? 1 : 0.33))
                                                .frame(width: UIScreen.main.bounds.width * 0.07, height: UIScreen.main.bounds.height * 0.005)
                                                .onTapGesture {
                                                    selected = dotIndex
                                                }
                                        }
                                    }
                                    
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.33)))
                                    // Adjust dot position
                                    Spacer()
                                }.frame(width: width * CGFloat(entry.width) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.width - 1), height: height * CGFloat(entry.height) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.height - 1))
                            }
                        }
                    }
                    .frame(width: width * CGFloat(entry.width) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.width - 1), height: height * CGFloat(entry.height) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.height - 1))
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hides default dots
                    .ignoresSafeArea()
                } else {
                    HStack {
                        Text("Upload")
                        Image(systemName: "camera")
                    }.frame(width: width * CGFloat(entry.width) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.width - 1), height: height * CGFloat(entry.height) + UIScreen.main.bounds.width * 0.02 * CGFloat(entry.height - 1))
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: entry.color[0], green: entry.color[1], blue: entry.color[2])))
                        
                }
                // Carousel
            }.frame(height: height, alignment: .top)
            .photosPicker(isPresented: $isPickerPresented, selection: $selectedItems)
            .onChange(of: selectedItems) {
                Task {
                    selectedImages.removeAll()
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImages.append(uiImage)
                        }
                    }
                    uiImages = selectedImages
                    imageURLs = []
                    var count = 0
                    print(1)
                    for image in selectedImages {
                        let imagePath = await fbVM.storeImage(image: image) { url in
                            if let url = url {
                                imageURLs.append(url)
                                userVM.addImageToUser(url: url, image: image)
                                count += 1
                            }
                            if count == selectedImages.count {
                                print("made it")
                                userVM.updateJournalEntry(journal: journal, pageNum: pageNum, entryIndex: entryIndex, newEntry: JournalEntry(entry: entry, width: entry.width, height: entry.height, color: entry.color, images: imageURLs, type: .image))
                                Task {
                                    await fbVM.updateJournalPage(entries: journal.pages[pageNum].entries, journalID: journal.id, pageNumber: pageNum)
                                }
                                timer?.invalidate()
                                selected = 0
                                timer = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: true) { _ in
                                    guard isActive else {
                                        selected = 0
                                        return
                                    }
                                    if (uiImages.count != 0) {
                                        selected = (selected + 1) % uiImages.count
                                    }
                                }
                            }

                        }
                    }
                }
            }
            .onChange(of: entry) {
                print("Entry changes")
                uiImages = []
                for image in entry.images {
                    if let uiImage = userVM.getImage(url: image) {
                        uiImages.append(uiImage)
                    }
                }
            }
            .onTapGesture {
                print(entry.images)
                if showDeleteButton != -1 {
                    showDeleteButton = -1
                    isWiggling = false
                } else {
                    isPickerPresented.toggle()
                }
            }
            .onAppear() {
                if frontDegrees < -90 {
                    
                    isActive = true
                    selected = 0
                    for image in entry.images {
                        if let uiImage = userVM.getImage(url: image) {
                            uiImages.append(uiImage)
                        }
                    }
                    if (entry.images.count != 0) {
                        timer = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: true) { _ in
                            guard isActive else {
                                selected = 0
                                return
                            }
                            if uiImages.count != 0 {
                                selected = (selected + 1) % uiImages.count
                            }
                        }
                    }
                }
            }
            .onChange(of: frontDegrees) {
                print("front degrees")
                if frontDegrees < 0 && !isActive {
                    isActive = true
                    selected = 0
                    for image in entry.images {
                        if let uiImage = userVM.getImage(url: image) {
                            uiImages.append(uiImage)
                        }
                    }
                    if (entry.images.count != 0) {
                        timer = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: true) { _ in
                            guard isActive else {
                                selected = 0
                                return
                            }
                            if uiImages.count != 0 {
                                selected = (selected + 1) % uiImages.count
                            }
                        }
                    }
                } else if frontDegrees == 0 {
                    isActive = false
                    timer?.invalidate()
                    timer = nil
                }
        
                
            }
        }
}

struct VoiceMemoEntryView: View {
    var entry: JournalEntry
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: entry.color[0], green: entry.color[1], blue: entry.color[2]))
                .frame(width: entry.frameWidth, height: entry.frameHeight)
                .opacity(entry.isFake ? 0 : 1)
                .frame(height: height, alignment: .center)

            VStack(spacing: 8) {
                Image(systemName: "waveform.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(.black)

                Text(entry.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(titleLineLimit)
                    .frame(width: entry.frameWidth - 16)
            }
            .padding(.horizontal, 8)
        }
    }

    var iconSize: CGFloat {
        switch entry.entrySize {
        case .small: return 25
        case .medium: return 35
        case .large: return 45
        }
    }

    var titleLineLimit: Int {
        switch entry.entrySize {
        case .small: return 1
        case .medium: return 2
        case .large: return 3
        }
    }
}




//#Preview {
//    struct Preview: View {
//        @ObservedObject var page: JournalPage = JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1)
//        @State var selectedImageIndex: Int = 0
//        @State var inTextEntry = false
//        @State var selectedEntry: Int = 0
//        @State var deleteEntry: Int = -1
//        var body: some View {
//            WidgetView(width: UIScreen.main.bounds.width * 0.38, height: UIScreen.main.bounds.height * 0.12, padding: 10, pageNum: 2, page: page, isDisplay: true, inTextEntry: $inTextEntry, selectedEntry: $selectedEntry, userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
//                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
//                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
//                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
//                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
//            ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), showDeleteButton: $deleteEntry, journal: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3), fbVM: FirebaseViewModel() )
//        }
//    }
//
//    return Preview()
//}

#Preview {
    struct Preview: View {
        @ObservedObject var page: JournalPage = JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1)
        @State var selectedImageIndex: Int = 0
        @State var inEntry: EntryType = .openJournal
        @State var selectedEntry: Int = 0
        @State var deleteEntry: Int = -1
        @State var frontDegrees: CGFloat = -180
        var body: some View {
            WidgetView(width: UIScreen.main.bounds.width * 0.38, height: UIScreen.main.bounds.height * 0.12, padding: 10, pageNum: 2, page: page, isDisplay: true, inEntry: $inEntry, selectedEntry: $selectedEntry, userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
                Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
            ]), JournalShelf(name: "Shelf 2", journals: [])], scrapbookShelves: [])), showDeleteButton: $deleteEntry, journal: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake")], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff"), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club")], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake"), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff")], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3), fbVM: FirebaseViewModel(), frontDegrees: $frontDegrees)
        }
    }

    return Preview()
}
