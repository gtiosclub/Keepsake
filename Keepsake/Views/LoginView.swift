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
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        NavigationStack {
            VStack {
                VStack{
                    HStack{
                        //Keepsake Logo?
                        Image(systemName: "book.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 120)
                            .padding(.vertical, 32)
                        
                        Text("KeepSake")
                            .font(.title)
                            .bold()
                            .padding()
                    }
                    
                    Text("KeepSake catch phrase")
                        .font(.body)
                        .padding()
                }.padding()
                
                
                
                
        
                
                
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
                .padding(.bottom)
                
                //sign in button
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .background(Color(.systemGreen).opacity(0.5))
                .cornerRadius(25)
                .padding(.horizontal, 16)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                Spacer()
                
                
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
