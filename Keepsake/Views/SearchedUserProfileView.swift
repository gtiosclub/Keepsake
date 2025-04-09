import FirebaseFirestore
import SwiftUI

struct SearchedUserProfileView: View {
    let currentUserID: User
    let selectedUserID: String

    @State private var selectedUser: User?
    @State private var isFriend: Bool = false
    @StateObject var firebaseViewModel = FirebaseViewModel()
    @StateObject private var viewModel = UserLookupViewModel()
    @Binding var friends: [String]

    var body: some View {
        VStack {
            if let user = selectedUser {
                List {
                    Section {
                        VStack {
                            
                            
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .foregroundColor(.gray)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.top)

                                    Text(user.username)
                                        .font(.footnote)
                                        .accentColor(.pink)

                                }
                            }
                        }
                    }
                    
//                    Button(action: {
//                        if (currentUserID.friends.contains(user.id)) {
//                            currentUserID.friends.remove(at: currentUserID.friends.firstIndex(of: user.id)!)
//                            viewModel.removeFriend(currentUserID: currentUserID.id, friendUserID: user.id)
//                            isFriend = false
//                        } else {
//                            currentUserID.friends.append(user.id)
//                            viewModel.addFriend(currentUserID: currentUserID.id, friendUserID: user.id)
//                            isFriend = true
//                        }
//                    }
//                    ) {
//                        
//                        Text(currentUserID.friends.contains(user.id) ? "Remove Friend" : "Add Friend")
//                            .foregroundColor(.pink)
//                            
//                    }
                    Button(action: {
                        if friends.contains(user.id) {
                            if let index = friends.firstIndex(of: user.id) {
                                friends.remove(at: index)
                            }
                            viewModel.removeFriend(currentUserID: currentUserID.id, friendUserID: user.id)
                            isFriend = false
                        } else {
                            friends.append(user.id)
                            viewModel.addFriend(currentUserID: currentUserID.id, friendUserID: user.id)
                            isFriend = true
                        }
                    }) {
                        Text(friends.contains(user.id) ? "Remove Friend" : "Add Friend")
                            .foregroundColor(.pink)
                    }

                }
                .onAppear {
                    isFriend = friends.contains(user.id)
                }

            } else {
                ProgressView("Loading user...")
            }
        }
        .task {
            await loadUser()
        }
    }

    @MainActor
    func loadUser() async {
        selectedUser = await firebaseViewModel.fetchOtherUser(
            newUserID: selectedUserID)
    }
}

//#Preview {
//    SearchedUserProfileView(
//        currentUserID: "OcWgLI1k78edVzsm1tthgXRPhTu2",
//        selectedUserID: "tjwUgNncOldWHgbbiEHzXmoXOr23")
//}
