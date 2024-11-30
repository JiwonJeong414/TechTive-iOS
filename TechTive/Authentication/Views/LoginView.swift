//
//  LoginView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var navigateToSignUp = false
    
    // Custom colors
    private let backgroundColor = Color(UIColor.color.darkPurple)
    private let cardBackground = Color(UIColor.color.backgroundColor)
    private let accentColor = Color(UIColor.color.orange)
    
    var body: some View {
        NavigationView{
            ZStack {
                // Background
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo
                    Spacer(minLength: 200)
                    Image("hat") // Make sure to add this asset
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 232.62, height: 152)
                    Spacer(minLength: 70)
                    // Login Card
                    VStack(spacing: 24) {
                        // Title
                        Text("LOGIN")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(UIColor.color.darkPurple))
                        
                        // Input fields
                        VStack(spacing: 16) {
                            TextField("Username", text: $username)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Login button
                        Button(action: {
                            authViewModel.login(username: username, password: password)
                        }) {
                            Text("Login")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(accentColor)
                                .cornerRadius(25)
                        }
                        
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            
                            NavigationLink(destination: SignUpView()) {
                                Text("Sign up")
                                    .foregroundColor(accentColor)
                            }
                        }
                        .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 450, alignment: .top)
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

// Custom text field style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
