import FirebaseFirestore
import SwiftUI
import FirebaseFirestore
import PhotosUI

struct SearchedUserProfileView: View {
    // MARK: - Properties
    let currentUserID: String
    let selectedUserID: String
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectUserInfo: UserInfoWithStreaks = UserInfoWithStreaks(userID: "", name: "Name", username: "Username", profilePic: UIImage(systemName: "person.circle"), friends: [], streakCount: 0)
    @State private var isFriend: Bool = false
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var viewModel: FirebaseViewModel
    @State var communityScrapbooks: [Scrapbook: [UserInfo]] = [:]
    @State var savedScrapbooks: [Scrapbook] = []
    @State private var layoutMetrics = LayoutMetrics()
    
    // MARK: - Layout Metrics
    private struct LayoutMetrics {
        var profileImageSize: CGFloat = 100
        var profileInfoSpacing: CGFloat = 20
        var horizontalPadding: CGFloat = 30
        var gridSpacing: CGFloat = 25
        var bookmarkSize: CGSize = CGSize(width: 20, height: 43)
        var userImageSize: CGFloat = 25
        var coverAspectRatio: CGFloat = 0.7
        var coverWidthFraction: CGFloat = 0.43
        
        var coverWidth: CGFloat {
            UIScreen.main.bounds.width * coverWidthFraction
        }
        
        var coverHeight: CGFloat {
            coverWidth / coverAspectRatio
        }
    }
    
    // MARK: - Main View
    var body: some View {
        VStack {
            profileHeader
            scrapbookGrid
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear(perform: loadInitialData)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: customBackButton)
    }
    
    // MARK: - Subviews
    
    private var profileHeader: some View {
        HStack(spacing: layoutMetrics.profileInfoSpacing) {
            profileImage
            
            VStack(alignment: .center, spacing: 8) {
                Text(selectUserInfo.username)
                    .font(.title3)
                    .accentColor(.pink)
                
                streakInfo
                
                friendButton
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 30)
    }
    
    private var profileImage: some View {
        Group {
            if let profilePic = selectUserInfo.profilePic {
                Image(uiImage: profilePic)
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
    }
    
    private var streakInfo: some View {
        Group {
            if let streak = selectUserInfo.streakCount {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Streak: \(streak)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var friendButton: some View {
        Button(action: toggleFriendStatus) {
            Text(isFriend ? "Remove Friend" : "Add Friend")
                .foregroundStyle(Color(hex: "#4CA5C0"))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "#7FD2E7").opacity(0.4))
                )
        }
    }
    
    private var scrapbookGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 200))],
                 spacing: 25) {
            ForEach(userVM.filterCommunityScrapbooks(userID: selectUserInfo.userID)) { scrapbook in
                scrapbookCard(scrapbook)
            }
        }
        .padding(.top, 20)
    }
    
    private func scrapbookCard(_ scrapbook: Scrapbook) -> some View {
        VStack(alignment: .center) {
            NavigationLink {
                CreateScrapbookView(fbVM: viewModel, userVM: userVM, scrapbook: scrapbook)
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
        .padding(.bottom, 20)
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
            
            HStack(spacing: 5) {
                if let profilePic = selectUserInfo.profilePic {
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
                
                Text("by \(selectUserInfo.name)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var customBackButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 25))
                    .foregroundStyle(.black)
                Text(selectUserInfo.name)
                    .font(.system(size: 35))
                    .foregroundStyle(.black)
            }
            .padding(.top, 20)
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadInitialData() {
        Task {
            selectUserInfo = await viewModel.getUserInfoWithStreaks(userID: selectedUserID) ?? selectUserInfo
            let currentFriends = await viewModel.getFriends(for: currentUserID)
            isFriend = currentFriends.contains(selectedUserID)
        }
        communityScrapbooks = userVM.getCommunityScrapbooks()
        savedScrapbooks = userVM.getSavedScrapbooks()
    }
    
    private func toggleFriendStatus() {
        if isFriend {
            viewModel.removeFriend(currentUserID: currentUserID, friendUserID: selectUserInfo.userID)
            if let index = selectUserInfo.friends.firstIndex(of: currentUserID) {
                selectUserInfo.friends.remove(at: index)
            }
        } else {
            userVM.addFriend(friendID: selectUserInfo.userID)
            viewModel.addFriend(currentUserID: currentUserID, friendUserID: selectUserInfo.userID)
            selectUserInfo.friends.append(currentUserID)
        }
        isFriend.toggle()
    }
    
    private func toggleSaveStatus(for scrapbook: Scrapbook) {
        if let index = savedScrapbooks.firstIndex(where: { $0.id == scrapbook.id }) {
            savedScrapbooks.remove(at: index)
        } else {
            savedScrapbooks.append(scrapbook)
        }
        userVM.updateSavedScrapbooks(scrapbooks: savedScrapbooks)
        Task {
            await viewModel.updateSavedScrapbooks(userID: userVM.user.id, newScrapbooks: savedScrapbooks)
        }
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
}
#Preview {
    SearchedUserProfileView(currentUserID: "OcWgLI1k78edVzsm1tthgXRPhTu2", selectedUserID: "user1", userVM: UserViewModel(user: User(id: "iddd", name: "Mr.Hance", username: "username", journalShelves: [], scrapbookShelves: [], savedTemplates: [], friends: [], lastUsedJShelfID: UUID(), lastUsedSShelfID: UUID(), isJournalLastUsed: false, images: [:], communityScrapbooks: [
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
)), viewModel: FirebaseViewModel())
}
