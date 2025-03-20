//
//  ProfileView.swift
//  Keepsake
//
//  Created by Nithya Ravula on 3/11/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
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
    //            Section("General") {
    //                SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
    //            }
                Section("Account") {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "hi",
                                        title: "Sign Out",
                                        tintColor: .red)
                    }
                    .foregroundColor(.pink)
                    
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
