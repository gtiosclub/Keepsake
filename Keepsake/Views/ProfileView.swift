import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        HStack {
                            Text(user.name)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())

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
                    
                    Section("Friends") {
                        NavigationLink(destination: FriendsView()) {
                            SettingsRowView(imageName: "person.2.fill",
                                            title: "View Friends",
                                            tintColor: .blue)
                        }
                    }

                    Section("Account") {
                        Button {
                            viewModel.signOut()
                        } label: {
                            SettingsRowView(imageName: "arrow.backward.circle.fill",
                                            title: "Sign Out",
                                            tintColor: .red)
                        }
                        .foregroundColor(.pink)
                    }
                }
                .navigationTitle("Profile")
            }
        }
    }
}

#Preview {
    ProfileView()
}
