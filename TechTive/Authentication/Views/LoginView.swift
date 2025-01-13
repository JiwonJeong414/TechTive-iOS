//
//  LoginView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // State variables for form fields
    @State private var email = ""
    @State private var password = ""
    
    // Custom colors
    private let backgroundColor = Color(UIColor.color.darkPurple)
    private let cardBackground = Color(UIColor.color.backgroundColor)
    private let accentColor = Color(UIColor.color.orange)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo
                    Spacer(minLength: 200)
                    Image("hat")
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
                            TextField("Email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Error Message
                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                        }
                        
                        // Login button with loading state
                        Button(action: {
                            Task {
                                await authViewModel.login(email: email, password: password)
                            }
                        }) {
                            ZStack {
                                Text("Login")
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
                        
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(.black)
                            
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
                    .padding(.vertical, 50)
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
