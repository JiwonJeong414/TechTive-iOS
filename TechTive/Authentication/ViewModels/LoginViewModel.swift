//
//  LoginViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var navigateToHome: Bool = false
    @Published var showError: Bool = false
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    private let auth = Auth.auth()
    
    // Check if user is already logged in
    func checkAuthState() {
        // Retain the listener handle to avoid the unused result warning
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
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
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            showError = true
            return
        }
        
        isLoading = true
        
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
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
