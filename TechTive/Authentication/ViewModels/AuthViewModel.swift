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
    @Published var currentUserName: String = ""
    @Published var currentUserEmail: String = ""
    @Published var profilePictureURL: String?
    
    private var stateListener: AuthStateDidChangeListenerHandle?
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        stateListener = auth.addStateDidChangeListener { [weak self] _, user in
            let authViewModel = self
            Task { @MainActor in
                if user != nil {
                    await authViewModel?.fetchUserInfo()
                    await authViewModel?.fetchProfilePicture()
                }
                authViewModel?.isAuthenticated = user != nil
            }
        }
    }
    deinit {
        if let listener = stateListener {
            auth.removeStateDidChangeListener(listener)
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
                        
                        self.isAuthenticated = true
                        self.fetchUserInfo()
                    }
                }
            }
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
                
                self.isAuthenticated = true
                self.fetchUserInfo()
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
    
    func fetchUserInfo() {
        guard let currentUser = auth.currentUser else {
            print("No current user logged in.")
            return
        }
        
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
                self.profilePictureURL = data["profilePictureURL"] as? String
            }
        }
    }
    
    func getCurrentUserId() -> String? {
        return auth.currentUser?.uid
    }
    
    
    func uploadProfilePicture(image: UIImage) async throws -> Bool {
        print("🔄 Starting profile picture upload")
        
        let token = try await getAuthToken()
        print("🔑 DEBUG - Token: \(token)")
        
        guard let apiURL = URL(string: "https://631c-128-84-124-32.ngrok-free.app/api/pfp/") else {
            print("❌ Invalid URL")
            throw URLError(.badURL)
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        let lineBreak = "\r\n"
        
        // Add image data to the raw HTTP request body
        data.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\"; filename=\"image.png\"\(lineBreak)".data(using: .utf8)!)
        data.append("Content-Type: image/png\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        
        // Convert UIImage to PNG data
        guard let imageData = image.pngData() else {
            print("❌ Failed to convert UIImage to PNG")
            throw URLError(.cannotCreateFile)
        }
        
        data.append(imageData)
        data.append(lineBreak.data(using: .utf8)!)
        data.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        
        let (responseData, response) = try await URLSession.shared.upload(for: request, from: data)
        
        if let responseString = String(data: responseData, encoding: .utf8) {
            print("📍 DEBUG - Response: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📥 DEBUG - Response status code: \(httpResponse.statusCode)")
        
        let success = (200...299).contains(httpResponse.statusCode)
        
        if success {
            let decoder = JSONDecoder()
            let profileResponse = try decoder.decode(ProfilePictureResponse.self, from: responseData)
            print("✅ Profile picture URL: \(profileResponse.link)")
            try await storeProfilePictureURL(imageUrl: profileResponse.link)
            return true
        } else {
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("❌ DEBUG - Server error response: \(responseString)")
            }
        }
        
        return false
    }
    
    private func storeProfilePictureURL(imageUrl: String) async throws {
        guard let userId = getCurrentUserId() else { return }
        
        try await db.collection("users").document(userId).updateData([
            "profilePictureURL": imageUrl
        ])
        
        await MainActor.run {
            self.profilePictureURL = imageUrl
        }
    }
    
    func fetchProfilePicture() async {
        guard let userId = getCurrentUserId() else { return }
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data(), let url = data["profilePictureURL"] as? String {
                self.profilePictureURL = url
            }
        } catch {
            print("Error fetching profile picture: \(error)")
        }
    }
    
    func fetchUserInfo() async {
        guard let currentUser = auth.currentUser else {
            print("No current user logged in.")
            return
        }
        
        do {
            let document = try await db.collection("users").document(currentUser.uid).getDocument()
            
            guard let data = document.data() else {
                print("No user data found")
                return
            }
            
            self.currentUserName = data["name"] as? String ?? ""
            self.currentUserEmail = data["email"] as? String ?? ""
            self.profilePictureURL = data["profilePictureURL"] as? String
        } catch {
            print("Error fetching user document: \(error)")
        }
    }
    
    func getAuthToken() async throws -> String {
        guard let currentUser = auth.currentUser else {
            throw URLError(.userAuthenticationRequired)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            currentUser.getIDToken { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let token = token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: URLError(.userAuthenticationRequired))
                }
            }
        }
    }
    
    func updateUsername(newUsername: String) async -> (Bool, String?) {
        guard let userId = auth.currentUser?.uid else {
            return (false, "User not authenticated.")
        }
        
        do {
            try await db.collection("users").document(userId).updateData(["name": newUsername])
            await MainActor.run {
                self.currentUserName = newUsername
            }
            return (true, nil)
        } catch {
            return (false, error.localizedDescription)
        }
    }
    
    func updateEmail(newEmail: String) async throws {
        guard let user = auth.currentUser else { throw URLError(.userAuthenticationRequired) }
        
        try await user.updateEmail(to: newEmail)
        guard let userId = getCurrentUserId() else { throw URLError(.userAuthenticationRequired) }
        
        try await db.collection("users").document(userId).updateData(["email": newEmail])
        await MainActor.run {
            self.currentUserEmail = newEmail
        }
    }
    
    func updatePassword(newPassword: String) async throws {
        guard let user = auth.currentUser else { throw URLError(.userAuthenticationRequired) }
        try await user.updatePassword(to: newPassword)
    }
}

struct ProfilePictureResponse: Codable {
    let link: String
    let message: String
}
