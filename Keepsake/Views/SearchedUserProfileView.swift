
import SwiftUI
import FirebaseFirestore
import PhotosUI

struct SearchedUserProfileView: View {
    let currentUserID: String
    let selectedUserID: String
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectUserInfo: UserInfo = UserInfo(userID: "", name: "Name", username: "Username", profilePic: UIImage(systemName: "person.circle"), friends: [])
    @State private var isFriend: Bool = false
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var viewModel: FirebaseViewModel
    @State var communityScrapbooks: [Scrapbook : [UserInfo]] = [:]
    @State var savedScrapbooks: [Scrapbook] = [] {
        didSet {
            userVM.updateSavedScrapbooks(scrapbooks: savedScrapbooks)
            Task {
                await viewModel.updateSavedScrapbooks(userID: userVM.user.id, newScrapbooks: savedScrapbooks)
            }
        }
    }
    @State var dummy: Bool = false
    @State var scaleEffect = 0.4
    //@StateObject private var viewModel = UserLookupViewModel()
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                if let profilePic = selectUserInfo.profilePic {
                    Image(uiImage: profilePic)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .center, spacing: 4) {
                    
                    Text(selectUserInfo.username)
                        .font(.title3)
                        .accentColor(.pink)
                    
                    Button(action: {
                        if selectUserInfo.friends.contains(currentUserID) {
                            // Remove friend locally
                            //                        if let index = viewModel.users.firstIndex(where: { $0.id == user.id }) {
                            //                            viewModel.users[index].friends.removeAll { $0 == currentUserID }
                            //                        }
                            //                        selectedUser?.friends.removeAll { $0 == currentUserID }
                            viewModel.removeFriend(currentUserID: currentUserID, friendUserID: selectUserInfo.userID)
                        } else {
                            // Add friend locally
                            //                        if let index = viewModel.users.firstIndex(where: { $0.id == user.id }) {
                            //                            viewModel.users[index].friends.append(currentUserID)
                            //                        }
                            //                        selectedUser?.friends.append(currentUserID)
                            userVM.addFriend(friendID: selectUserInfo.userID)
                            viewModel.addFriend(currentUserID: currentUserID, friendUserID: selectUserInfo.userID)
                        }
                    }) {
                        Text(selectUserInfo.friends.contains(currentUserID) ? "Remove Friend" : "Add Friend")
                            .foregroundStyle(Color(hex: "#4CA5C0"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    .foregroundColor(.pink)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#7FD2E7").opacity(0.4))
                    )
                    
                }
                
                
                
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30)
            grid.padding(.top, 20)
            Spacer()
            
        }.padding(.horizontal, 30)
            .onAppear() {
                Task {
                    selectUserInfo = await viewModel.getUserInfo(userID: selectedUserID) ?? selectUserInfo
                }
                communityScrapbooks = userVM.getCommunityScrapbooks()
                savedScrapbooks = userVM.getSavedScrapbooks()
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
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
            )
    }
    
    var grid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 25) {
            ForEach(userVM.filterCommunityScrapbooks(userID: selectUserInfo.userID)) { scrapbook in
                VStack(alignment: .center) {
                    NavigationLink {
                        CreateScrapbookView(fbVM: viewModel, userVM: userVM, scrapbook: scrapbook)
                    } label: {
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
                    }
                    
                    VStack(alignment: .center, spacing: 3) {
                        Text(scrapbook.name)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 5) {
                            if let profilePic = selectUserInfo.profilePic {
                                Image(uiImage: profilePic)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 25, height: 25)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                            }
                            Text("by \(selectUserInfo.name)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    SearchedUserProfileView(currentUserID: "OcWgLI1k78edVzsm1tthgXRPhTu2", selectedUserID: "tjwUgNncOldWHgbbiEHzXmoXOr23", userVM: UserViewModel(user: User()), viewModel: FirebaseViewModel())
}
