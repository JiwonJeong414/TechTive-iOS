import SwiftUI

import FirebaseAuth
import FirebaseFirestore
import Foundation

class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var navigateToHome = false
    @Published var showError = false // Added this line

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    func signUp() {
        // Basic validation
        guard !self.name.isEmpty else {
            self.errorMessage = "Please enter your name"
            self.showError = true // Set this to true when there's an error
            return
        }

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

        guard self.password == self.confirmPassword else {
            self.errorMessage = "Passwords don't match"
            self.showError = true
            return
        }

        self.isLoading = true

        self.auth.createUser(withEmail: self.email, password: self.password) { [weak self] result, error in
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

                        DispatchQueue.main.async {
                            self.showError = false
                            // Trigger any action to return to the login page
                        }
                    }
                }
            }
        }
    }
}
