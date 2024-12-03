//
//  SignUpView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI
import FirebaseAuth
import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // State variables for form fields
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
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
                    Spacer(minLength: 70)
                    Image("magnifyingTwo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 232.62, height: 152)
                    Spacer(minLength: 10)
                    
                    // Sign Up Card
                    VStack(spacing: 24) {
                        // Title
                        Text("SIGN UP")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(UIColor.color.darkPurple))
                        
                        // Input fields
                        VStack(spacing: 16) {
                            TextField("Name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Error Message (if any)
                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                        }
                        
                        // Sign Up button with loading state
                        Button(action: {
                            if password == confirmPassword {
                                authViewModel.signUp(email: email, password: password, name: name)
                            } else {
                                authViewModel.errorMessage = "Passwords don't match"
                                authViewModel.showError = true
                            }
                        }) {
                            ZStack {
                                Text("Sign Up")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .opacity(authViewModel.isLoading ? 0 : 1)
                                
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(accentColor)
                            .cornerRadius(25)
                        }
                        .disabled(authViewModel.isLoading)
                        
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.black)
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Log in")
                                    .foregroundColor(accentColor)
                            }
                        }
                        .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 470, alignment: .top)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .background(cardBackground)
                    .cornerRadius(30)
                }
            }
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authViewModel.errorMessage)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
