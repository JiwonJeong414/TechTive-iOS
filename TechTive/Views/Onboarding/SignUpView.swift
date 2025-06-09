//
//  SignUpView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI

/// A view that handles user registration with email and password
struct SignUpView: View {
    // MARK: - Properties

    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss

    private let backgroundColor = Color(Constants.Colors.darkPurple)
    private let cardBackground = Color(Constants.Colors.backgroundColor)
    private let accentColor = Color(Constants.Colors.orange)

    // MARK: - UI

    var body: some View {
        NavigationView {
            ZStack {
                self.backgroundColor.ignoresSafeArea()
                VStack(spacing: 30) {
                    self.logoSection
                    self.signUpCard
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
            Spacer(minLength: 70)
            Image("magnifyingTwo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 232.62, height: 152)
            Spacer(minLength: 10)
        }
    }

    private var signUpCard: some View {
        VStack(spacing: 24) {
            self.titleSection
            self.inputFields
            self.errorMessage
            self.signUpButton
            self.loginLink
        }
        .frame(maxWidth: .infinity)
        .frame(height: 470, alignment: .top)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(self.cardBackground)
        .cornerRadius(30)
    }

    private var titleSection: some View {
        Text("SIGN UP")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(Color(Constants.Colors.darkPurple))
    }

    private var inputFields: some View {
        VStack(spacing: 16) {
            TextField("Name", text: self.$viewModel.name)
                .textFieldStyle(CustomTextFieldStyle())
                .autocapitalization(.none)

            TextField("Email", text: self.$viewModel.email)
                .textFieldStyle(CustomTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: self.$viewModel.password)
                .textFieldStyle(CustomTextFieldStyle())
                .textContentType(.oneTimeCode)

            SecureField("Confirm Password", text: self.$viewModel.confirmPassword)
                .textFieldStyle(CustomTextFieldStyle())
                .textContentType(.oneTimeCode)
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

    private var signUpButton: some View {
        Button(action: {
            Task {
                await self.viewModel.signUp()
            }
        }) {
            ZStack {
                Text("Sign Up")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(self.viewModel.isLoading ? 0 : 1)

                if self.viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(self.accentColor)
            .cornerRadius(25)
        }
        .disabled(self.viewModel.isLoading)
    }

    private var loginLink: some View {
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
}
