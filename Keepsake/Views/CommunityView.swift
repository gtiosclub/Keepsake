//
//  CommunityView.swift
//  Keepsake
//
//  Created by Connor on 2/5/25.
//
import SwiftUI


struct CommunityView: View {
    // MARK: - Properties (keep all your existing properties)
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    @State var communityScrapbooks: [Scrapbook: [UserInfo]] = [:]
    @State var savedScrapbooks: [Scrapbook] = []
    @State var indexedScrapbooks: [Scrapbook] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var searchText = ""
    @State private var selectedViewType = "Public Works"
    @State private var layoutMetrics = LayoutMetrics()
    @State var retrievedImage: UIImage?
    
    // MARK: - Adaptive Layout Metrics
    private struct LayoutMetrics {
        var coverAspectRatio: CGFloat = 0.7 // Width to height ratio
        var coverWidthFraction: CGFloat = 0.43 // Fraction of screen width
        var coverHeight: CGFloat {
            return coverWidth / coverAspectRatio
        }
        var coverWidth: CGFloat {
            return UIScreen.main.bounds.width * coverWidthFraction
        }
        var bookmarkSize: CGSize = CGSize(width: 20, height: 43)
        var profileImageSize: CGFloat = 50
        var userImageSize: CGFloat = 25
    }
    
    // MARK: - Views
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    headerView
                    searchBarView
                    viewTypePicker
                    scrapbooksGrid
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: loadInitialData)
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Text("Community")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                profileImage
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
    }
    
    private var searchBarView: some View {
        NavigationLink(destination: UserSearchView(viewModel: fbVM, userVM: userVM)) {
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
    
    private var viewTypePicker: some View {
        HStack(spacing: 15) {
            ForEach(viewTypes, id: \.self) { type in
                Button(action: { selectedViewType = type }) {
                    VStack(spacing: 4) {
                        Text(type)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedViewType == type ? .primary : .gray)
                        
                        Capsule()
                            .frame(height: 2)
                            .foregroundColor(selectedViewType == type ? .primary : .clear)
                            .frame(width: type == "Public Works" ? 100 : 70)
                    }
                    .frame(width: 100)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    private var scrapbooksGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 25)]) {
            ForEach(filteredScrapbooks) { scrapbook in
                scrapbookCard(scrapbook)
            }
            
            if isLoading {
                ProgressView()
                    .frame(width: layoutMetrics.coverWidth,
                           height: layoutMetrics.coverHeight)
                    .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func scrapbookCard(_ scrapbook: Scrapbook) -> some View {
        VStack(alignment: .center) {
            NavigationLink {
                CreateScrapbookView(fbVM: fbVM, userVM: userVM, scrapbook: scrapbook)
            } label: {
                ZStack {
                    JournalCover(
                        template: scrapbook.template,
                        degrees: 0,
                        title: scrapbook.name,
                        showOnlyCover: .constant(false),
                        offset: false
                    )
                    .scaleEffect(scaleEffect)
                    .frame(width: layoutMetrics.coverWidth,
                           height: layoutMetrics.coverHeight)
                    .clipped()
        
                    
                    bookmarkView(for: scrapbook)
                }
            }
            
            scrapbookDetails(for: scrapbook)
        }
        .padding(.bottom, 10)
    }
    
    private func bookmarkView(for scrapbook: Scrapbook) -> some View {
        SharpBookmark()
            .rotationEffect(.degrees(180))
            .frame(width: layoutMetrics.bookmarkSize.width,
                   height: layoutMetrics.bookmarkSize.height)
            .offset(x: layoutMetrics.coverWidth * 0.3,
                    y: -layoutMetrics.coverHeight * 0.387)
            .foregroundStyle(
                savedScrapbooks.contains { $0.id == scrapbook.id } ? .yellow : .white
            )
            .onTapGesture {
                toggleSaveStatus(for: scrapbook)
            }
            
    }
    
    private func scrapbookDetails(for scrapbook: Scrapbook) -> some View {
        VStack(alignment: .center, spacing: 3) {
            Text(scrapbook.name)
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if let users = communityScrapbooks[scrapbook],
               let firstUser = users.first {
                userInfoView(firstUser)
            } else {
                defaultUserInfoView
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func userInfoView(_ user: UserInfo) -> some View {
        HStack(spacing: 5) {
            if let profilePic = user.profilePic {
                Image(uiImage: profilePic)
                    .resizable()
                    .scaledToFill()
                    .frame(width: layoutMetrics.userImageSize,
                           height: layoutMetrics.userImageSize)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: layoutMetrics.userImageSize,
                           height: layoutMetrics.userImageSize)
            }
            
            Text("by \(user.name)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
    
    private var defaultUserInfoView: some View {
        HStack(spacing: 5) {
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: layoutMetrics.userImageSize * 0.6,
                       height: layoutMetrics.userImageSize * 0.6)
            
            Text("by User")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
    
    private var profileImage: some View {
        Group {
            if let profileImage = retrievedImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: layoutMetrics.profileImageSize,
                           height: layoutMetrics.profileImageSize)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: layoutMetrics.profileImageSize,
                           height: layoutMetrics.profileImageSize)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    private var scaleEffect: CGFloat {
        let originalWidth = UIScreen.main.bounds.width * 0.9
        let originalHeight = UIScreen.main.bounds.height * 0.56
        let originalAspect = originalWidth / originalHeight
        
        let targetWidth = layoutMetrics.coverWidth
        let targetHeight = layoutMetrics.coverHeight
        let targetAspect = targetWidth / targetHeight
        
        // Calculate scale based on which dimension is more constrained
        if originalAspect > targetAspect {
            // Width-constrained (original is wider than target)
            return targetWidth / originalWidth
        } else {
            // Height-constrained (original is taller than target)
            return targetHeight / originalHeight
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadInitialData() {
        communityScrapbooks = userVM.getCommunityScrapbooks()
        savedScrapbooks = userVM.getSavedScrapbooks()
        Task {
            await loadCommunityScrapbooks()
        }
    }
    
    private func toggleSaveStatus(for scrapbook: Scrapbook) {
        if let index = savedScrapbooks.firstIndex(where: { $0.id == scrapbook.id }) {
            savedScrapbooks.remove(at: index)
        } else {
            savedScrapbooks.append(scrapbook)
        }
        userVM.updateSavedScrapbooks(scrapbooks: savedScrapbooks)
        Task {
            await fbVM.updateSavedScrapbooks(userID: userVM.user.id, newScrapbooks: savedScrapbooks)
        }
    }
    
    private func loadCommunityScrapbooks() async {
        isLoading = true
        error = nil
        
        do {
            let userIDs = try await fbVM.getAllUserIDs()
            
            for userID in userIDs {
                do {
                    let scrapbooks = try await fbVM.getUserSharedScrapbooks(userID: userID)
                    
                    await MainActor.run {
                        for (scrapbook, userInfos) in scrapbooks {
                            if !indexedScrapbooks.contains(where: { $0.id == scrapbook.id }) {
                                indexedScrapbooks.append(scrapbook)
                            }
                            
                            if var existingUsers = communityScrapbooks[scrapbook] {
                                let newUserInfos = userInfos.filter { newUser in
                                    !existingUsers.contains { $0.userID == newUser.userID }
                                }
                                existingUsers.append(contentsOf: newUserInfos)
                                communityScrapbooks[scrapbook] = existingUsers
                            } else {
                                communityScrapbooks[scrapbook] = userInfos
                            }
                            userVM.setCommunityScrapbooks(scrapbooks: communityScrapbooks)
                        }
                    }
                } catch {
                    print("Error fetching scrapbooks for user \(userID): \(error)")
                }
            }
            
            await MainActor.run {
                userVM.setCommunityScrapbooks(scrapbooks: communityScrapbooks)
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Computed Properties
    
    var filteredScrapbooks: [Scrapbook] {
        switch selectedViewType {
        case "Saved": return savedScrapbooks
        default: return indexedScrapbooks
        }
    }
    
    let viewTypes = ["Public Works", "Saved"]
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
        Scrapbook(
            name: "Scrap 1",
            id: UUID(),
            createdDate: todaysdate(),
            category: "General",
            isSaved: false,
            isShared: true,
            template: Template(
                name: "",
                coverColor: .red,
                pageColor: .white,
                titleColor: .black,
                texture: .leather,
                journalPages: []
            ),
            pages: [],
            currentPage: 0
        ): [
            (userID: "user1", name: "Bill", username: "username", profilePic: UIImage(systemName: "person.cirle"), friends: [])
        ],
        Scrapbook(
            name: "Scrap 2",
            id: UUID(),
            createdDate: todaysdate(),
            category: "General",
            isSaved: false,
            isShared: true,
            template: Template(
                name: "",
                coverColor: .red,
                pageColor: .white,
                titleColor: .black,
                texture: .leather,
                journalPages: []
            ),
            pages: [],
            currentPage: 0
        ): [
            (userID: "user1", name: "Bill", username: "username", profilePic: UIImage(systemName: "person.cirle"), friends: [])
        ]
    ]
)), fbVM: FirebaseViewModel())
}
