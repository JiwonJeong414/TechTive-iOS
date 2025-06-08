//
//  LoginView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import FirebaseAuth
import GoogleSignIn
import Inject
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    // State variables for form fields
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    // Custom colors
    private let backgroundColor = Color(UIColor.color.darkPurple)
    private let cardBackground = Color(UIColor.color.backgroundColor)
    private let accentColor = Color(UIColor.color.orange)

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                self.backgroundColor.ignoresSafeArea()

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
                            TextField("Email", text: self.$email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .disabled(self.authViewModel.isLoading)

                            HStack {
                                if self.isPasswordVisible {
                                    TextField("Password", text: self.$password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                } else {
                                    SecureField("Password", text: self.$password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }

                                Button(action: {
                                    self.isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: self.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                                .disabled(self.authViewModel.isLoading)
                            }
                        }

                        // Error Message
                        if !self.authViewModel.errorMessage.isEmpty {
                            Text(self.authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                        }

                        // Login button with loading state
                        Button(action: {
                            Task {
                                await self.authViewModel.login(email: self.email, password: self.password)
                            }
                        }) {
                            ZStack {
                                Text("Login")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .opacity(self.authViewModel.isLoading ? 0 : 1)

                                if self.authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(self.accentColor)
                            .cornerRadius(25)
                        }
                        .disabled(self.authViewModel.isLoading)

                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            Text("OR")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.vertical, 10)

                        // Google Sign In Button
                        Button(action: {
                            Task {
                                await self.authViewModel.signInWithGoogle()
                            }
                        }) {
                            HStack {
                                Image("google_logo") // Make sure to add this image to your assets
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Sign in with Google")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        .disabled(self.authViewModel.isLoading)

                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(.black)

                            NavigationLink(destination: SignUpView()) {
                                Text("Sign up")
                                    .foregroundColor(self.accentColor)
                            }
                        }
                        .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 550, alignment: .top) // Increased height to accommodate Google button
                    .padding(.horizontal, 24)
                    .padding(.vertical, 50)
                    .background(self.cardBackground)
                    .cornerRadius(30)
                }
            }
        }
        .alert("Error", isPresented: self.$authViewModel.showError) {
            Button("OK", role: .cancel) {
                self.authViewModel.errorMessage = ""
            }
        } message: {
            Text(self.authViewModel.errorMessage)
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
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
