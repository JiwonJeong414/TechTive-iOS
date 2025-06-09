//
//  LoginView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import FirebaseAuth
import GoogleSignIn
import SwiftUI

/// A view that handles user authentication through email/password and Google Sign-In
struct LoginView: View {
    // MARK: - Properties

    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    private let backgroundColor = Color(Constants.Colors.darkPurple)
    private let cardBackground = Constants.Colors.backgroundColor
    private let accentColor = Constants.Colors.orange

    // MARK: - UI

    var body: some View {
        NavigationView {
            ZStack {
                self.backgroundColor.ignoresSafeArea()
                VStack(spacing: 30) {
                    self.logoSection
                    self.loginCard
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

    // MARK: - UI Components

    private var logoSection: some View {
        VStack {
            Spacer(minLength: 200)
            Image("hat")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 232.62, height: 152)
            Spacer(minLength: 70)
        }
    }

    private var loginCard: some View {
        VStack(spacing: 24) {
            self.titleSection
            self.inputFields
            self.errorMessage
            self.loginButton
            self.divider
            self.googleSignInButton
            self.signUpLink
        }
        .frame(maxWidth: .infinity)
        .frame(height: 550, alignment: .top)
        .padding(.horizontal, 24)
        .padding(.vertical, 50)
        .background(Color(self.cardBackground))
        .cornerRadius(30)
    }

    private var titleSection: some View {
        Text("LOGIN")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(Color(Constants.Colors.darkPurple))
    }

    private var inputFields: some View {
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
    }

    private var errorMessage: some View {
        Group {
            if !self.authViewModel.errorMessage.isEmpty {
                Text(self.authViewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var loginButton: some View {
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
            .background(Color(self.accentColor))
            .cornerRadius(25)
        }
        .disabled(self.authViewModel.isLoading)
    }

    private var divider: some View {
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
    }

    private var googleSignInButton: some View {
        Button(action: {
            Task {
                await self.authViewModel.signInWithGoogle()
            }
        }) {
            HStack {
                Image("google_logo")
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
    }

    private var signUpLink: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundColor(.black)

            NavigationLink(destination: SignUpView()) {
                Text("Sign up")
                    .foregroundColor(Color(self.accentColor))
            }
        }
        .font(.system(size: 14))
    }
}
