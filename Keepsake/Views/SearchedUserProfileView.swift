import FirebaseFirestore
import SwiftUI

struct SearchedUserProfileView: View {
    let currentUserID: User
    let selectedUserID: String

    @State private var selectedUser: User?
    @State private var isFriend: Bool = false
    @StateObject var firebaseViewModel = FirebaseViewModel()
    @StateObject private var viewModel = UserLookupViewModel()

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

                        if currentUserID.friends.contains(selectedUserID) {
                            // Remove friend locally
                            if let index = viewModel.users.firstIndex(where: {
                                $0.id == currentUserID.id
                            }) {
                                viewModel.users[index].friends.removeAll {
                                    $0 == selectedUserID
                                }
                            }
                            viewModel.removeFriend(
                                currentUserID: currentUserID.id,
                                friendUserID: user.id)
                        } else {
                            // Add friend locally
                            if let index = viewModel.users.firstIndex(where: {
                                $0.id == currentUserID.id
                            }) {
                                viewModel.users[index].friends.append(
                                    selectedUserID)
                            }
                            viewModel.addFriend(
                                currentUserID: currentUserID.id,
                                friendUserID: user.id)
                        }
                    }) {
                        Text(
                            currentUserID.friends.contains(selectedUserID)
                                ? "Remove Friend" : "Add Friend"
                        )
                        .foregroundColor(.pink)
                    }

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
