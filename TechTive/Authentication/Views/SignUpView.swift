//
//  SignUpView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI


struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Name", text: $viewModel.name)
                TextField("Email", text: $viewModel.email)
                SecureField("Password", text: $viewModel.password)
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                
                Button("Sign Up") {
                    viewModel.signUp()
                }
            }
            .padding()
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)  // Hide the back button
    }
}

#Preview{
    SignUpView()
}
