//
//  LoginView.swift
//  Keepsake
//
//  Created by Nithya Ravula on 3/10/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: FirebaseViewModel
    var body: some View {
        NavigationStack {
            VStack {
                //Keepsake Logo?
                Image("Dog Image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                    .padding(.vertical, 32)
                
                
                //form fields
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecure: true)
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                //sign in button
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 40)
                    
                }
                .background(Color(.systemPink))
                .disabled(!formIsValid)
                .opacity(formIsValid  ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                
                Spacer()
                
                //sign up button
                
                NavigationLink {
                    RegistrationView()
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                            .foregroundColor(.pink)
                        Text("Sign up")
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                    }
                    .font(.system(size: 14))
                    
                    
                }
            }
        }
    }
    
}
extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
}
