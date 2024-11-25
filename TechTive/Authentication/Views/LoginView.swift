//
//  LoginView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

// MARK: - Auth Views (Login/SignUp remained the same)
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Login") {
                // Update login logic to use authViewModel
                authViewModel.login(username: username, password: password)
            }
        }
        .padding()
    }
}

#Preview{
    LoginView()
}
