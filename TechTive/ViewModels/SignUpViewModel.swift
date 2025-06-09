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
    @Published var showError = false
    @Published var isLoading = false
    @Published var navigateToHome = false

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    func signUp() async {
        // Basic validation
        guard !self.name.isEmpty else {
            await MainActor.run {
                self.errorMessage = "Please enter your name"
                self.showError = true
            }
            return
        }

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

        guard self.password == self.confirmPassword else {
            await MainActor.run {
                self.errorMessage = "Passwords don't match"
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
            let result = try await auth.createUser(withEmail: self.email, password: self.password)
            let user = result.user

            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "userId": user.uid,
                "createdAt": Date()
            ]

            try await self.db.collection("users").document(user.uid).setData(userData)

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
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                self.errorMessage = "An account with this email already exists"
            case AuthErrorCode.weakPassword.rawValue:
                self.errorMessage = "Password is too weak. Please use a stronger password"
            case AuthErrorCode.tooManyRequests.rawValue:
                self.errorMessage = "Too many attempts. Please try again later"
            default:
                self.errorMessage = error.localizedDescription
        }
        self.showError = true
    }

    func clearError() {
        self.errorMessage = ""
        self.showError = false
    }
}
