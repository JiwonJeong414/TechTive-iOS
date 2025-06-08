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
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var navigateToHome = false
    @Published var showError = false
    private var authStateListener: AuthStateDidChangeListenerHandle?

    private let auth = Auth.auth()

    // Check if user is already logged in
    func checkAuthState() {
        // Retain the listener handle to avoid the unused result warning
        self.authStateListener = self.auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if user != nil {
                    self?.navigateToHome = true
                } else {
                    self?.navigateToHome = false
                }
            }
        }
    }

    deinit {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }

    func login() {
        guard !self.email.isEmpty else {
            self.errorMessage = "Please enter your email"
            self.showError = true
            return
        }

        guard !self.password.isEmpty else {
            self.errorMessage = "Please enter your password"
            self.showError = true
            return
        }

        self.isLoading = true

        self.auth.signIn(withEmail: self.email, password: self.password) { [weak self] result, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    return
                }

                guard let user = result?.user else {
                    self.errorMessage = "Failed to log in"
                    self.showError = true
                    return
                }

                print("Logged in with: \(user.email ?? "")")
                self.navigateToHome = true
            }
        }
    }
}
