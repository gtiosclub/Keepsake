//
//  CommunityView.swift
//  Keepsake
//
//  Created by Connor on 2/5/25.
//
import SwiftUI


struct CommunityView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    @State var communityScrapbooks: [Scrapbook] = []
    @State var savedScrapbooks: [Scrapbook] = [] {
        didSet {
            userVM.updateSavedScrapbooks(scrapbooks: savedScrapbooks)
            Task {
                await fbVM.updateSavedScrapbooks(userID: userVM.user.id, newScrapbooks: savedScrapbooks)
            }
        }
    }
    @State var scaleEffect = 0.4
    @State private var searchText = ""
    @StateObject private var viewModel = UserLookupViewModel()
    @State var dummy: Bool = false
    @State var retrievedImage: UIImage?
    @State private var selectedViewType = "Public Works" // New state for picker
    
    let viewTypes = ["Public Works", "Saved"] // Picker options
    
    var filteredScrapbooks: [Scrapbook] {
        switch selectedViewType {
        case "Saved":
            return savedScrapbooks
        default:
            return communityScrapbooks
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        HStack {
                            Text("Community")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            profileImage
                        }.padding(.horizontal, 20)
                        
                        // Search bar
                        NavigationLink(destination: UserSearchView()) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Text("Search for users...")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Picker for view type
                    HStack(spacing: 15) {  // Reduced from 30 to 20
                        ForEach(viewTypes, id: \.self) { type in
                            Button(action: {
                                selectedViewType = type
                            }) {
                                VStack(spacing: 4) {
                                    Text(type)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(selectedViewType == type ? .primary : .gray)
                                    
                                    Capsule()
                                        .frame(height: 2)
                                        .foregroundColor(selectedViewType == type ? .primary : .clear)
                                        .frame(width: type == "Public Works" ? 100 : 70)  // Custom width for each underline
                                }
                                .frame(width: 100)  // Fixed width for each option
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    
                    // Scrapbooks grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 25) {
                        ForEach(filteredScrapbooks) { scrapbook in
                            VStack(alignment: .center) {
                                ZStack {
                                    JournalCover(
                                        template: scrapbook.template,
                                        degrees: 0,
                                        title: scrapbook.name,
                                        showOnlyCover: $dummy,
                                        offset: false
                                    )
                                    .transition(.identity)
                                    .scaleEffect(scaleEffect)
                                    .frame(
                                        width: UIScreen.main.bounds.width * 0.4,
                                        height: UIScreen.main.bounds.height * 0.25
                                    )
                                    SharpBookmark()
                                        .rotationEffect(.degrees(180))
                                        .frame(width: 20, height: 43)
                                        .offset(x: 40, y: -77)
                                        .foregroundStyle(
                                                savedScrapbooks.contains(where: { $0.id == scrapbook.id }) ?
                                                .yellow :
                                                .white)
                                        .onTapGesture(perform: {
                                            if let index = savedScrapbooks.firstIndex(where: { $0.id == scrapbook.id }) {
                                                savedScrapbooks.remove(at: index)
                                            } else {
                                                savedScrapbooks.append(scrapbook)
                                            }
                                        })
                                }
                                
                                VStack(alignment: .center, spacing: 3) {
                                    Text(scrapbook.name)
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                    
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 15, height: 15)
                                        
                                        Text("by User")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear() {
            communityScrapbooks = userVM.getCommunityScrapbooks()
            savedScrapbooks = userVM.getSavedScrapbooks()
        }
    }
    
    var profileImage: some View {
        HStack(alignment: .center, spacing: 16) {
            if let profileImage = retrievedImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct SharpBookmark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let creviceDepth: CGFloat = 8 // Adjust this value to change crevice depth
        
        // Start at bottom-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Left side up to mid-left point
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - creviceDepth))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Right side down to bottom-right corner

        
        // Close path back to starting point
        path.closeSubpath()
        
        return path
    }
}

// SortOptionButton component
struct SortOptionButton: View {
    var label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Capsule().stroke(Color.black, lineWidth: 1))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    CommunityView(userVM: UserViewModel(user: User(id: "iddd", name: "Mr.Hance", username: "username", journalShelves: [], scrapbookShelves: [], savedTemplates: [], friends: [], lastUsedJShelfID: UUID(), lastUsedSShelfID: UUID(), isJournalLastUsed: false, images: [:], communityScrapbooks: [
        Scrapbook(name: "Scrap 1", id: UUID(), createdDate: todaysdate(), category: "General", isSaved: false, isShared: true, template: Template(name: "", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather, journalPages: []), pages: [], currentPage: 0),
        Scrapbook(name: "Scrap 2", id: UUID(), createdDate: todaysdate(), category: "General", isSaved: false, isShared: true, template: Template(name: "", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather, journalPages: []), pages: [], currentPage: 0),
        Scrapbook(name: "Scrap 3", id: UUID(), createdDate: todaysdate(), category: "General", isSaved: false, isShared: true, template: Template(name: "", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather, journalPages: []), pages: [], currentPage: 0)
    ])), fbVM: FirebaseViewModel())
}
