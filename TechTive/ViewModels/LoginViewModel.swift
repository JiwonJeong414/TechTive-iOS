//
//  LoginViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordVisible = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    @Published var navigateToHome = false

    private let auth = Auth.auth()
    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        self.setupAuthStateListener()
    }

    deinit {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }

    private func setupAuthStateListener() {
        self.authStateListener = self.auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.navigateToHome = user != nil
            }
        }
    }

    func login() async {
        // Input validation
        guard !self.email.isEmpty else {
            await MainActor.run {
                self.errorMessage = "Please enter your email"
                self.showError = true
            }
            return
        }

        guard !self.password.isEmpty else {
            await MainActor.run {
                self.errorMessage = "Please enter your password"
                self.showError = true
            }
            return
        }

        // Email format validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: self.email) else {
            await MainActor.run {
                self.errorMessage = "Please enter a valid email address"
                self.showError = true
            }
            return
        }

        await MainActor.run {
            self.isLoading = true
        }

        do {
            let result = try await auth.signIn(withEmail: self.email, password: self.password)
            await MainActor.run {
                self.isLoading = false
                self.navigateToHome = true
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.handleAuthError(error)
            }
        }
    }

    private func handleAuthError(_ error: Error) {
        let errorCode = (error as NSError).code
        switch errorCode {
            case AuthErrorCode.invalidEmail.rawValue:
                self.errorMessage = "Invalid email format"
            case AuthErrorCode.wrongPassword.rawValue:
                self.errorMessage = "Incorrect password"
            case AuthErrorCode.userNotFound.rawValue:
                self.errorMessage = "No account found with this email"
            case AuthErrorCode.userDisabled.rawValue:
                self.errorMessage = "This account has been disabled"
            case AuthErrorCode.tooManyRequests.rawValue:
                self.errorMessage = "Too many attempts. Please try again later"
            default:
                self.errorMessage = error.localizedDescription
        }
        self.showError = true
    }

    func togglePasswordVisibility() {
        self.isPasswordVisible.toggle()
    }

    func clearError() {
        self.errorMessage = ""
        self.showError = false
    }
}
