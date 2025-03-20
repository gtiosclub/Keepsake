//
//  FirstView.swift
//  Keepsake
//
//  Created by Nithya Ravula on 3/12/25.
//

import SwiftUI

struct FirstView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                ProfileView()
            } else {
                LoginView()
            }



        }
    }
}

#Preview {
    FirstView()
}
