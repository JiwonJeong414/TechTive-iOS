//
//  SignUpView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import FirebaseAuth
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    // State variables for form fields
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // Custom colors (to maintain consistency)
    private let backgroundColor = Color(Constants.Colors.darkPurple)
    private let cardBackground = Color(Constants.Colors.backgroundColor)
    private let accentColor = Color(Constants.Colors.orange)

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                self.backgroundColor.ignoresSafeArea()

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
                            .foregroundColor(Color(Constants.Colors.darkPurple))

                        // Input fields
                        VStack(spacing: 16) {
                            TextField("Name", text: self.$name)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)

                            TextField("Email", text: self.$email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)

                            SecureField("Password", text: self.$password)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textContentType(.oneTimeCode)

                            SecureField("Confirm Password", text: self.$confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textContentType(.oneTimeCode)
                        }

                        // Error Message (if any)
                        if !self.authViewModel.errorMessage.isEmpty {
                            Text(self.authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                        }

                        // Sign Up button with loading state
                        Button(action: {
                            if self.password == self.confirmPassword {
                                Task {
                                    await self.authViewModel.signUp(
                                        email: self.email,
                                        password: self.password,
                                        name: self.name)
                                }
                            } else {
                                self.authViewModel.errorMessage = "Passwords don't match"
                                self.authViewModel.showError = true
                            }
                        }) {
                            ZStack {
                                Text("Sign Up")
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

                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.black)
                            Button(action: {
                                self.dismiss()
                            }) {
                                Text("Log in")
                                    .foregroundColor(self.accentColor)
                            }
                        }
                        .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 470, alignment: .top)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .background(self.cardBackground)
                    .cornerRadius(30)
                }
            }
        }
        .alert("Error", isPresented: self.$authViewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(self.authViewModel.errorMessage)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
