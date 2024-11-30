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
    
    // Custom colors (to maintain consistency)
    private let backgroundColor = Color(UIColor.color.darkPurple)
    private let cardBackground = Color(UIColor.color.backgroundColor)
    private let accentColor = Color(UIColor.color.orange)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image("magnifyingTwo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 232.62, height: 152)
                    
                    // Sign Up Card
                    VStack(spacing: 24) {
                        // Title
                        Text("SIGN UP")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(UIColor.color.darkPurple))
                        
                        // Input fields
                        VStack(spacing: 16) {
                            TextField("Name", text: $viewModel.name)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            TextField("Email", text: $viewModel.email)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            SecureField("Password", text: $viewModel.password)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Sign Up button
                        Button(action: {
                            viewModel.signUp()
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(accentColor)
                                .cornerRadius(25)
                        }
                        
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.gray)
                            
                            NavigationLink(destination: LoginView()) {
                                Text("Log in")
                                    .foregroundColor(accentColor)
                            }
                        }
                        .font(.system(size: 14))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .background(cardBackground)
                    .cornerRadius(30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)  // Hide the back button
    }
}

#Preview {
    SignUpView()
}

