//
//  AuthViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseCore


class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isLoading: Bool = false
    @Published var isSignedIn = false
    private var stateListener: AuthStateDidChangeListenerHandle?

    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        // Store the listener handle
        stateListener = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
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
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            isAuthenticated = false
        } catch {
            errorMessage = "Error signing out"
            showError = true
        }
    }
    
    
    func signInWithGoogle() async {
            isLoading = true
            
            do {
                // Get client ID and configure Google Sign In
                guard let clientID = FirebaseApp.app()?.options.clientID else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get client ID"])
                }
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.configuration = config
                
                // Get root view controller
                guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = await windowScene.windows.first,
                      let rootViewController = await window.rootViewController else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get root view controller"])
                }
                
                // Sign in with Google
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                
                guard let idToken = result.user.idToken?.tokenString else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get ID token"])
                }
                
                // Create Firebase credential
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: result.user.accessToken.tokenString
                )
                
                // Sign in to Firebase
                let authResult = try await Auth.auth().signIn(with: credential)
                
                // Save user data to Firestore
                let userData: [String: Any] = [
                    "name": result.user.profile?.name ?? "",
                    "email": result.user.profile?.email ?? "",
                    "userId": authResult.user.uid,
                    "createdAt": Date()
                ]
                
                try await db.collection("users").document(authResult.user.uid).setData(userData)
                
                // Set authenticated state
                await MainActor.run {
                    self.isAuthenticated = true
                }
                
            } catch {
                print("Google Sign In error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
            
            isLoading = false
        }

}
