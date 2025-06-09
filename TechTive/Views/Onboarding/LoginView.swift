//
//  LoginView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI

/// A view that handles user authentication through email/password and Google Sign-In
struct LoginView: View {
    // MARK: - Properties

    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

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
        .alert("Error", isPresented: self.$viewModel.showError) {
            Button("OK", role: .cancel) {
                self.viewModel.clearError()
            }
        } message: {
            Text(self.viewModel.errorMessage)
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
            TextField("Email", text: self.$viewModel.email)
                .textFieldStyle(CustomTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .disabled(self.viewModel.isLoading)

            HStack {
                if self.viewModel.isPasswordVisible {
                    TextField("Password", text: self.$viewModel.password)
                        .textFieldStyle(CustomTextFieldStyle())
                } else {
                    SecureField("Password", text: self.$viewModel.password)
                        .textFieldStyle(CustomTextFieldStyle())
                }

                Button(action: {
                    self.viewModel.togglePasswordVisibility()
                }) {
                    Image(systemName: self.viewModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
                .disabled(self.viewModel.isLoading)
            }
        }
    }

    private var errorMessage: some View {
        Group {
            if !self.viewModel.errorMessage.isEmpty {
                Text(self.viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var loginButton: some View {
        Button(action: {
            Task {
                await self.viewModel.login()
            }
        }) {
            ZStack {
                Text("Login")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(Constants.Colors.white))
                    .opacity(self.viewModel.isLoading ? 0 : 1)

                if self.viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(self.accentColor))
            .cornerRadius(25)
        }
        .disabled(self.viewModel.isLoading)
    }

    private var divider: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(Constants.Colors.gray).opacity(0.3))
            Text("OR")
                .font(.system(size: 14))
                .foregroundColor(Color(Constants.Colors.gray))
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(Constants.Colors.gray).opacity(0.3))
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
                    .foregroundColor(Color(Constants.Colors.black))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(Constants.Colors.white))
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color(Constants.Colors.gray).opacity(0.2), lineWidth: 1))
        }
        .disabled(self.viewModel.isLoading)
    }

    private var signUpLink: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundColor(Color(Constants.Colors.black))

            NavigationLink(destination: SignUpView()) {
                Text("Sign up")
                    .foregroundColor(Color(self.accentColor))
            }
        }
        .font(.system(size: 14))
    }
}
