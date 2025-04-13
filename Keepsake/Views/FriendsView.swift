import SwiftUI
import FirebaseFirestore

struct FriendsView: View {
    @EnvironmentObject var viewModel: FirebaseViewModel
    @State private var friendsList: [User] = []
    @State private var selectedUserID: String?
    private let db = Firestore.firestore()

    func fetchFriends() {
        guard let userID = viewModel.currentUser?.id else { return }

        db.collection("USERS").document(userID).getDocument { snapshot, error in
            if let data = snapshot?.data(), let friendIDs = data["friends"] as? [String] {
                self.friendsList = []

                for friendID in friendIDs {
                    db.collection("USERS").document(friendID).getDocument { friendSnapshot, friendError in
                        if let friendData = friendSnapshot?.data(), friendError == nil {
                            let friend = User(
                                id: friendID,
                                name: friendData["name"] as? String ?? "Unknown",
                                username: friendData["username"] as? String ?? "",
                                journalShelves: [],
                                scrapbookShelves: [],
                                savedTemplates: [],
                                friends: friendData["friends"] as? [String] ?? [],
                                lastUsedJShelfID: friendData["lastUsedJShelfID"] as? UUID ?? UUID(),
                                lastUsedSShelfID: friendData["lastUsedSShelfID"] as? UUID ?? UUID(),
                                isJournalLastUsed: true
                            )

                            DispatchQueue.main.async {
                                self.friendsList.append(friend)
                            }
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if friendsList.isEmpty {
                        Text("No Friends Yet")
                    } else {
                        ForEach(friendsList, id: \.id) { friend in
                            NavigationLink(
                                destination: SearchedUserProfileView(
                                    currentUserID: viewModel.currentUser?.id ?? "",
                                    selectedUserID: friend.id,
                                    userVM: UserViewModel(user: friend),
                                    viewModel: viewModel
                                )
                            ) {
                                HStack {
                                    Image("firebase image")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                        .clipShape(Circle())
                                        .frame(width: 80, height: 80)

                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(friend.name)
                                            .padding(.bottom, -7)
                                        Text(friend.username)
                                            .font(.system(size: 12))
                                            .opacity(0.6)
                                    }

                                    Spacer()

                                    Button(action: {
                                        removeFriend(friendID: friend.id)
                                    }) {
                                        Text("Remove")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.pink)
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 35)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .navigationBarTitle("Friends")
            }
            .onAppear {
                fetchFriends()
            }
        }
    }

    func removeFriend(friendID: String) {
        guard let userID = viewModel.currentUser?.id else { return }
        let userRef = db.collection("USERS").document(userID)

        userRef.updateData([
            "friends": FieldValue.arrayRemove([friendID])
        ]) { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.friendsList.removeAll { $0.id == friendID }
                }
            }
        }
    }
}
