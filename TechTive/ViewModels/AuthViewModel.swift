//
//  AuthViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import Alamofire
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import SwiftUI

@MainActor class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isSecondState = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    @Published var isSignedIn = false
    @Published var currentUserName = ""
    @Published var currentUserEmail = ""
    @Published var profilePictureURL: String?
    @Published var isLoadingUserInfo = false
    @Published var isInitializing = true // Start with true
    @Published var profileImage: UIImage?

    private var stateListener: AuthStateDidChangeListenerHandle?
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    init() {
        self.isInitializing = true
        self.stateListener = self.auth.addStateDidChangeListener { [weak self] _, user in
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
        self.isLoading = true
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = result.user

            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "userId": user.uid,
                "createdAt": Date()
            ]

            try await self.db.collection("users").document(user.uid).setData(userData)

            self.isLoading = false
            self.isAuthenticated = true
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
        // Input validation
        guard !email.isEmpty else {
            self.errorMessage = "Please enter your email"
            self.showError = true
            return
        }

        guard !password.isEmpty else {
            self.errorMessage = "Please enter your password"
            self.showError = true
            return
        }

        // Email format validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            self.errorMessage = "Please enter a valid email address"
            self.showError = true
            return
        }

        self.isLoading = true
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            self.isLoading = false

            // Update user info
            self.currentUserEmail = result.user.email ?? ""
            // Fetch additional user info from Firestore
            if let userDoc = try? await self.db.collection("users").document(result.user.uid).getDocument(),
               let userData = userDoc.data()
            {
                self.currentUserName = userData["name"] as? String ?? ""
            }

            self.isAuthenticated = true
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                // Handle specific Firebase Auth errors
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
        }
    }

    func signOut() {
        do {
            try self.auth.signOut()
            self.isAuthenticated = false
            self.isSecondState = true
            // Clear user data
            self.currentUserName = ""
            self.currentUserEmail = ""
            self.profilePictureURL = nil
        } catch {
            self.errorMessage = "Error signing out"
            self.showError = true
        }
    }

    func getCurrentUserId() -> String? {
        return self.auth.currentUser?.uid
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
                multipartFormData.append(
                    imageData,
                    withName: "ImageFile", // Changed from "image" to "ImageFile"
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
                        case let .success(profileResponse):
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
                        case let .failure(error):
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

        try await self.db.collection("users").document(userId).updateData([
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
            print(
                "❌ Error fetching user document for UID \(currentUser.uid) at \(Date()): \(error.localizedDescription)")
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
        guard let userId = getCurrentUserId() else { return (false, "No user logged in") }

        do {
            let data: [String: Any] = ["name": newUsername]
            try await self.db.collection("users").document(userId).updateData(data)
            await MainActor.run {
                self.currentUserName = newUsername
            }
            return (true, nil)
        } catch {
            return (false, error.localizedDescription)
        }
    }

    func updateEmail(newEmail: String) async throws {
        guard let user = auth.currentUser else { throw NSError(
            domain: "",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "No user logged in"]) }

        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
        self.currentUserEmail = newEmail
    }

    func updatePassword(newPassword: String) async throws {
        guard let user = auth.currentUser else { throw NSError(
            domain: "",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "No user logged in"]) }
        try await user.updatePassword(to: newPassword)
    }

    func deleteUser() async throws {
        guard let user = auth.currentUser,
              let userId = getCurrentUserId() else
        {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found."])
        }

        // Delete user Firestore data first
        try await self.db.collection("users").document(userId).delete()

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

    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else
        {
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString)

            // Sign in with Firebase
            let authResult = try await auth.signIn(with: credential)
            let user = authResult.user

            // Check if user exists in Firestore
            let userDoc = try await db.collection("users").document(user.uid).getDocument()

            if !userDoc.exists {
                // Create new user document
                let userData: [String: Any] = [
                    "name": result.user.profile?.name ?? "",
                    "email": result.user.profile?.email ?? "",
                    "userId": user.uid,
                    "createdAt": Date()
                ]

                try await self.db.collection("users").document(user.uid).setData(userData)
            }

            // Update local user info
            self.currentUserEmail = user.email ?? ""
            self.currentUserName = result.user.profile?.name ?? ""
            self.isAuthenticated = true

        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

    func loadProfilePicture() async {
        await self.fetchProfilePicture()
        if let urlString = profilePictureURL, let url = URL(string: urlString) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.profileImage = image
                    }
                }
            } catch {
                print("Error loading profile picture: \(error)")
            }
        }
    }
}

struct ProfilePictureResponse: Codable {
    let link: String
    let message: String
}
