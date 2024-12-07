//
//  SignUpViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

import Foundation
import FirebaseAuth
import FirebaseFirestore

class SignUpViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var navigateToHome: Bool = false
    @Published var showError: Bool = false  // Added this line
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    func signUp() {
        // Basic validation
        guard !name.isEmpty else {
            errorMessage = "Please enter your name"
            showError = true  // Set this to true when there's an error
            return
        }
        
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
        
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            showError = true
            return
        }
        
        isLoading = true
        
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    return
                }
                
                guard let user = result?.user else {
                    self.errorMessage = "Failed to create user"
                    self.showError = true
                    return
                }
                
                let userData: [String: Any] = [
                    "name": self.name,
                    "email": self.email,
                    "userId": user.uid,
                    "createdAt": Date()
                ]
                
                self.db.collection("users").document(user.uid).setData(userData) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            self.showError = true
                            return
                        }
                        
                        self.navigateToHome = true
                    }
                }
            }
        }
    }
}
