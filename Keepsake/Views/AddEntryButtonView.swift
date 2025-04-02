//
//  AddEntryButtonView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/26/25.
//

//
//  AddEntryButtonView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/26/25.
//

import SwiftUI
import PhotosUI

struct AddEntryButtonView: View {
    @State var isExpanded: Bool = false
    @ObservedObject var journal: Journal
    @Binding var inEntry: EntryType
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    @Binding var displayPage: Int
    @Binding var selectedEntry: Int
    @State var selectedItems = [PhotosPickerItem]()
    @State var selectedImages = [UIImage]()
    @State private var widgetsOrStickers: Int = 0
    var body: some View {
        VStack {
            if !isExpanded {
                if selectedImages.count == 0 {
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.black)
                        
                    }
                } else {
                    SelectedPhotoView(journal: journal, displayPage: displayPage, selectedEntry: selectedEntry, userVM: userVM, selectedImages: $selectedImages, selectedItems: $selectedItems, fbVM: fbVM)
                }
            }
        }
        .sheet(isPresented: $isExpanded) {
            VStack {
                ZStack {
                    Text("Components")
                        .font(.title2)
                        .fontWeight(.bold)
                    HStack {
                        Spacer()
                        Button {
                            isExpanded = false
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.title)
                        }
                    }
                }
                .padding()
                Picker("", selection: $widgetsOrStickers) {
                    Text("Widgets").tag(0)
                    Text("Stickers").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                if widgetsOrStickers == 0 {
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    LazyVGrid(columns: columns, spacing: 20) {
                        Button {
                            
                        } label: {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: UIScreen.main.bounds.width / 2 - 30,
                                           height: UIScreen.main.bounds.width / 2 - 40)
                                    .foregroundStyle(Color(hex: "#8cc0ff"))
                                
                                Text("Blank\nwidget")
                                    .multilineTextAlignment(.leading)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(25)
                            }
                        }
                        Button {
                            
                        } label: {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: UIScreen.main.bounds.width / 2 - 30, height: UIScreen.main.bounds.width / 2 - 40)
                                    .foregroundStyle(Gradient(colors: [Color(hex: "#5087c8"), Color(hex: "#2c486a")]))
                                
                                Text("Prompt of\nthe Day 💭")
                                    .multilineTextAlignment(.leading)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(25)
                            }
                        }
                        Button {
                            
                        } label: {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: UIScreen.main.bounds.width / 2 - 30, height: UIScreen.main.bounds.width / 2 - 40)
                                    .foregroundStyle(Color(hex: "#3468a5"))
                                
                                Text("Voice\nmemo 🎙️")
                                    .multilineTextAlignment(.leading)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(25)
                            }
                        }
                        Button {
                            
                        } label: {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: UIScreen.main.bounds.width / 2 - 30, height: UIScreen.main.bounds.width / 2 - 40)
                                    .foregroundStyle(Color(hex: "#a9cef9"))
                                
                                Text("Echo 🌐")
                                    .multilineTextAlignment(.leading)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(25)
                            }
                        }
                        Button {
                            
                        } label: {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: UIScreen.main.bounds.width / 2 - 30, height: UIScreen.main.bounds.width / 2 - 40)
                                    .foregroundStyle(.white)
                                    .shadow(radius: 4)
                                
                                Text("📷\nUpload\nphotos")
                                    .multilineTextAlignment(.leading)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.gray)
                                    .padding(25)
                            }
                        }
                    }
                    .padding()
                } else {
                    Text("Sticker Stuff")
                }
                Spacer()
            }
        }
//            if isExpanded {
//                
//                HStack {
//                    Button(action: {
//                        
//                        if journal.pages[journal.currentPage].entries.count <= 8 {
//                            selectedEntry = userVM.newAddJournalEntry(journal: journal, pageNum: displayPage, entry: JournalEntry(date: "", title: "", text: "", summary: "***", width: 10, height: 1, isFake: false, color: (0..<3).map { _ in Double.random(in: 0.5...0.99) }))
//                            var newIndex = 0
//                            switch journal.pages[journal.currentPage].realEntryCount {
//                            case 1: newIndex = 0
//                            case 2: newIndex = 4
//                            case 3: newIndex = 1
//                            case 4: newIndex = 3
//                            case 5: newIndex = 6
//                            case 6: newIndex = 7
//                            case 7: newIndex = 5
//                            default: newIndex = 2
//                            }
//                        } else {
//                            //handle too many entries
//                        }
//                        withTransaction(Transaction(animation: .none)) {
//                            inTextEntry.toggle()
//                        }
//                    }) { Image(systemName: "t.square.fill")
//                            .resizable()
//                            .frame(width: 45, height: 45)
//                        .foregroundColor(.black)}
//                    PhotosPicker(selection: $selectedItems, label: {
//                        Image(systemName: "photo.fill")
//                            .resizable()
//                            .frame(width: 45, height: 45)
//                            .foregroundColor(.blue)
//                    }).onChange(of: selectedItems) {
//                        Task {
//                            selectedImages.removeAll()
//                            for item in selectedItems {
//                                if let data = try? await item.loadTransferable(type: Data.self),
//                                   let uiImage = UIImage(data: data) {
//                                    selectedImages.append(uiImage)
//                                }
//                            }
//                        }
//                        withTransaction(Transaction(animation: .none)) {
//                            isExpanded.toggle()
//                        }
//                    }
//                    Button {
//                        
//                    } label: {
//                        Image(systemName: "face.smiling.inverse")
//                            .resizable()
//                            .frame(width: 45, height: 45)
//                            .foregroundColor(.yellow)
//                    }
//                    Button(action: {
//                        withAnimation(.easeInOut(duration: 0.3)) {
//                            isExpanded.toggle()
//                        }
//                    }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .resizable()
//                            .frame(width: 45, height: 45)
//                        .foregroundColor(.red)}
//                }.transition(.move(edge: .trailing).combined(with: .opacity))
//                    .padding(.trailing, 10)
//            }
//        }
    }
}

struct ToastView: View {

    @Binding var isShowing: Bool
    let message: String
    var body: some View {
        ZStack {
            if isShowing {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary)
                    .opacity(0.8)
                    .frame(height: 50)
                    .overlay(alignment: .center) {
                        Text(message)
                            .foregroundColor(.white)
                    }
                    .padding()
            }
        }
    }
}

struct SelectedPhotoView: View {
    @State var journal: Journal
    @State var displayPage: Int
    @State var selectedEntry: Int
    @ObservedObject var userVM: UserViewModel
    @Binding var selectedImages: [UIImage]
    @Binding var selectedItems: [PhotosPickerItem]
    @ObservedObject var fbVM: FirebaseViewModel
    @State var imageURLs: [String] = []
    var body: some View {
        HStack {
            Button {
                if journal.pages[journal.currentPage].entries.count <= 8 {
                    print(selectedImages)
                    Task {
                        imageURLs = []
                        var count = 0
                        for image in selectedImages {
                            let imagePath = await fbVM.storeImage(image: image) { url in
                                if let url = url {
                                    imageURLs.append(url)
                                    count += 1
//                                    print()
//                                    print("added")
                                }
                                if count == selectedImages.count {
                                    selectedEntry = userVM.newAddJournalEntry(journal: journal, pageNum: displayPage, entry: JournalEntry(date: "", title: "", text: "", summary: "", width: 1, height: 1, isFake: false, color: (0..<3).map { _ in Double.random(in: 0.5...0.99) }, images: imageURLs))
//                                    print()
//                                    print(journal.pages[displayPage].entries[selectedEntry])
//                                    print()
                                    Task {
                                        await fbVM.updateJournalPage(entries: journal.pages[displayPage].entries, journalID: journal.id, pageNumber: displayPage)
                                        selectedImages = []
                                        selectedItems = []
                                    }
                                }
                            }
                        }
                    }
                } else {
                    //handle too many entries
                }
            } label: {
                ZStack {
                    Text("Add widget with \(selectedImages.count) photos")
                        .font(.caption)
                        .foregroundStyle(.black)
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black)
                        )
                }
            }
            Button {
                selectedImages = []
                selectedItems = []
            } label: {
                ZStack {
                    Text("Dismiss")
                        .font(.caption)
                        .padding(5)
                        .foregroundStyle(.black)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black)
                        )
                }
            }
            
        }.frame(height: UIScreen.main.bounds.height * 0.05)
    }
    
}




#Preview {
    struct Preview: View {
        @State var inEntry: EntryType = .openJournal
        @State var displayPage = 2
        @State var selectedEntry = 0
        @ObservedObject var userVM: UserViewModel = UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", journals: [
            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 2, height: 2, isFake: false, color: [0.55, 0.8, 0.8]), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 1, height: 2, isFake: false, color: [0.5, 0.9, 0.7]), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff", width: 1, height: 2, isFake: false, color: [0.6, 0.7, 0.6]), JournalEntry(), JournalEntry(), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club", width: 2, height: 2, isFake: false, color: [0.9, 0.5, 0.8]), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 2, height: 2, isFake: false, color: [0.5, 0.9, 0.7]), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club", width: 2, height: 2, isFake: false, color: [0.6, 0.55, 0.8]), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .bears), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .stars), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: Texture.green), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ]), JournalShelf(name: "Shelf 2", journals: [
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .red, pageColor: .black, titleColor: .white, texture: .flower1), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ])], scrapbookShelves: []))
        var body: some View {
            AddEntryButtonView(journal: userVM.getJournal(shelfIndex: 0, bookIndex: 0), inEntry: $inEntry, userVM: userVM, fbVM: FirebaseViewModel(), displayPage: $displayPage, selectedEntry: $selectedEntry)
        }
    }

    return Preview()
}


