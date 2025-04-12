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

                    Button(action: {
                        Task {
                            guard let currentUser = firebaseViewModel.currentUser else { return }

                            if currentUser.friends.contains(user.id) {
                                await viewModel.removeFriend(currentUserID: currentUser.id, friendUserID: user.id)
                            } else {
                                await viewModel.addFriend(currentUserID: currentUser.id, friendUserID: user.id)
                            }

                            await firebaseViewModel.fetchUser()
                        }
                    }) {
                        Text(
                            (firebaseViewModel.currentUser?.friends.contains(user.id) == true)
                            ? "Remove Friend"
                            : "Add Friend"
                        )
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
