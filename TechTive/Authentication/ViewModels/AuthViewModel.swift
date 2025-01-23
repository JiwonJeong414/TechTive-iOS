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
import Alamofire

@MainActor
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
    @Published var isLoadingUserInfo: Bool = false
    @Published var isInitializing = true  // Start with true
    
    
    private var stateListener: AuthStateDidChangeListenerHandle?
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        isInitializing = true
        stateListener = auth.addStateDidChangeListener { [weak self] _, user in
            let authViewModel = self
            Task { @MainActor in
                if user != nil {
                    authViewModel?.isLoadingUserInfo = true
                    // Don't set isAuthenticated yet
                    await authViewModel?.fetchUserInfo()
                    await authViewModel?.fetchProfilePicture()
                    // Now set both flags
                    await MainActor.run {
                        authViewModel?.isAuthenticated = true
                        authViewModel?.isLoadingUserInfo = false
                    }
                } else {
                    await MainActor.run {
                        authViewModel?.isAuthenticated = false
                    }
                }
                await MainActor.run {
                    authViewModel?.isInitializing = false
                }
            }
        }
    }
    
    deinit {
        if let listener = stateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
    
    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = result.user
            
            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "userId": user.uid,
                "createdAt": Date()
            ]
            
            try await db.collection("users").document(user.uid).setData(userData)
            
            isLoading = false
            isAuthenticated = true
            // Removed fetchUserInfo() since stateListener handles it
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        do {
            let _ = try await auth.signIn(withEmail: email, password: password)
            isLoading = false
            isAuthenticated = true
            // Removed fetchUserInfo() since stateListener handles it
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
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
    
    
    func getCurrentUserId() -> String? {
        return auth.currentUser?.uid
    }
    
    func uploadProfilePicture(image: UIImage) async throws -> Bool {
        print("🔄 Starting profile picture upload")
        
        let token = try await getAuthToken()
        
        guard let apiURL = URL(string: "http://34.21.62.193/api/pfp/") else {
            print("❌ Invalid URL")
            throw URLError(.badURL)
        }
        
        // Compress image before upload
        let maxSizeKB = 1024 // 1MB
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)!
        
        while imageData.count / 1024 > maxSizeKB && compression > 0.1 {
            compression -= 0.1
            if let compressedData = image.jpegData(compressionQuality: compression) {
                imageData = compressedData
            }
        }
        
        print("📤 Compressed image size: \(imageData.count / 1024)KB")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "multipart/form-data"
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData,
                                         withName: "ImageFile",  // Changed from "image" to "ImageFile"
                                         fileName: "profile.jpg",
                                         mimeType: "image/jpeg")
            }, to: apiURL, headers: headers)
            .validate()
            .responseString { response in
                print("📥 Raw response: \(response.value ?? "no response")")
                print("📥 Response status code: \(response.response?.statusCode ?? -1)")
            }
            .responseDecodable(of: ProfilePictureResponse.self) { response in
                switch response.result {
                case .success(let profileResponse):
                    print("✅ Profile picture URL: \(profileResponse.link)")
                    Task {
                        do {
                            try await self.storeProfilePictureURL(imageUrl: profileResponse.link)
                            continuation.resume(returning: true)
                        } catch {
                            print("❌ Error storing profile URL: \(error)")
                            continuation.resume(throwing: error)
                        }
                    }
                case .failure(let error):
                    print("❌ Upload failed: \(error.localizedDescription)")
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print("❌ Server response: \(responseString)")
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
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
            print("🔴 No current user logged in.")
            return
        }
        
        print("🟢 Fetching user info for UID: \(currentUser.uid) at \(Date())")
        
        do {
            let document = try await db.collection("users").document(currentUser.uid).getDocument()
            
            guard let data = document.data() else {
                print("❌ No user data found for UID: \(currentUser.uid) at \(Date())")
                return
            }
            
            await MainActor.run {
                self.currentUserName = data["name"] as? String ?? ""
                self.currentUserEmail = data["email"] as? String ?? ""
                self.profilePictureURL = data["profilePictureURL"] as? String
                print("✅ User info fetched: \(self.currentUserName), \(self.currentUserEmail) at \(Date())")
            }
        } catch {
            print("❌ Error fetching user document for UID \(currentUser.uid) at \(Date()): \(error.localizedDescription)")
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
    
    func deleteUser() async throws {
        guard let user = auth.currentUser,
              let userId = getCurrentUserId() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found."])
        }
        
        // Delete user Firestore data first
        try await db.collection("users").document(userId).delete()
        
        // Delete authentication record
        try await user.delete()
        
        await MainActor.run {
            self.isAuthenticated = false
            self.currentUserEmail = ""
            self.currentUserName = ""
            self.profilePictureURL = nil
        }
        print("✅ User deleted successfully.")
    }

}

struct ProfilePictureResponse: Codable {
    let link: String
    let message: String
}
