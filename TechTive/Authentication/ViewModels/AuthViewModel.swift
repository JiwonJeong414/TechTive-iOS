//
//  AuthViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore


class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isSecondState = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isLoading: Bool = false
    @Published var isSignedIn = false
    private var stateListener: AuthStateDidChangeListenerHandle?
    
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        stateListener = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if user != nil {
                    self?.fetchUserInfo()
                }
            }
        }
    }
    
    deinit {
        if let listener = stateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
    
    func login(email: String, password: String) {
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
                
                // Successfully logged in
                self.isAuthenticated = true
                self.fetchUserInfo()
            }
        }
    }
    
    func signUp(email: String, password: String, name: String) {
        isLoading = true
        
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isLoading = false
                    return
                }
                
                guard let user = result?.user else {
                    self.errorMessage = "Failed to create user"
                    self.showError = true
                    self.isLoading = false
                    return
                }
                
                // Save additional user data to Firestore
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "userId": user.uid,
                    "createdAt": Date()
                ]
                
                self.db.collection("users").document(user.uid).setData(userData) { error in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            self.showError = true
                            return
                        }
                        
                        // Successfully created user and saved data
                        self.isAuthenticated = true
                        self.fetchUserInfo()
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            isAuthenticated = false
            isSecondState = true
        } catch {
            errorMessage = "Error signing out"
            showError = true
        }
    }
    
    @Published var currentUserName: String = ""
    @Published var currentUserEmail: String = ""
    
    func fetchUserInfo() {
        guard let currentUser = auth.currentUser else {
            print("No current user logged in.")
            return
        }
        
        // Fetch and print the user's ID token
        currentUser.getIDToken { token, error in
            if let error = error {
                print("Error fetching ID token: \(error.localizedDescription)")
                return
            }
            
            if let token = token {
                print("User token: \(token)")
            }
        }
        
        // Fetch additional user info from Firestore
        let userId = currentUser.uid
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self,
                  let document = document,
                  let data = document.data() else {
                print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.currentUserName = data["name"] as? String ?? ""
                self.currentUserEmail = data["email"] as? String ?? ""
            }
        }
    }

    func getCurrentUserId() -> String? {
        return auth.currentUser?.uid
    }
}

extension AuthViewModel {
    func updateUsername(newUsername: String, completion: @escaping (Bool, String?) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(false, "User not authenticated.")
            return
        }

        // Update username in Firestore
        db.collection("users").document(userId).updateData(["name": newUsername]) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    completion(false, error.localizedDescription)
                }
            } else {
                DispatchQueue.main.async {
                    self?.currentUserName = newUsername
                    completion(true, nil)
                }
            }
        }
    }

    func updateEmail(newEmail: String) {
        guard let user = auth.currentUser else { return }
        user.updateEmail(to: newEmail) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            } else {
                // Persist new email in Firestore
                guard let userId = self?.getCurrentUserId() else { return }
                self?.db.collection("users").document(userId).updateData(["email": newEmail]) { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.errorMessage = error.localizedDescription
                            self?.showError = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.currentUserEmail = newEmail
                        }
                    }
                }
            }
        }
    }

    func updatePassword(newPassword: String) {
        guard let user = auth.currentUser else { return }
        user.updatePassword(to: newPassword) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }
}

