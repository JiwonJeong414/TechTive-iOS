import Alamofire
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import SwiftUI

/// ViewModel responsible for handling authentication and user management
@MainActor class AuthViewModel: ObservableObject {
    // MARK: - Published Properties

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
    @Published var isInitializing = true
    @Published var profileImage: UIImage?
    @Published var isLoadingProfileImage = false // Track image loading state

    // MARK: - Private Properties

    private var stateListener: AuthStateDidChangeListenerHandle?
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var imageLoadTask: Task<Void, Never>? // NEW: Track ongoing load task

    // MARK: - Initialization

    init() {
        self.isInitializing = true
        self.stateListener = self.auth.addStateDidChangeListener { [weak self] _, user in
            let authViewModel = self
            Task { @MainActor in
                if user != nil {
                    authViewModel?.isLoadingUserInfo = true
                    await authViewModel?.fetchUserInfo()
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
        imageLoadTask?.cancel()
    }

    // MARK: - Authentication Methods

    /// Signs up a new user with email and password
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

            // Update local user info
            await MainActor.run {
                self.currentUserName = name
                self.currentUserEmail = email
                self.isLoading = false
                self.isAuthenticated = true
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    /// Logs in a user with email and password
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

    /// Signs out the current user
    func signOut() {
        do {
            try self.auth.signOut()
            self.isAuthenticated = false
            self.isSecondState = true
            // Clear user data
            self.currentUserName = ""
            self.currentUserEmail = ""
            self.profilePictureURL = nil
            self.profileImage = nil // Clear cached image
            
            // Cancel any ongoing image load
            imageLoadTask?.cancel()
        } catch {
            self.errorMessage = "Error signing out"
            self.showError = true
        }
    }

    /// Signs in with Google
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

    // MARK: - User Management Methods

    /// Updates the username for the current user
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

    /// Updates the email for the current user
    func updateEmail(newEmail: String) async throws {
        guard let user = auth.currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
        self.currentUserEmail = newEmail
    }

    /// Updates the password for the current user
    func updatePassword(newPassword: String) async throws {
        guard let user = auth.currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        try await user.updatePassword(to: newPassword)
    }

    /// Deletes the current user account
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
            self.isSecondState = true
            self.currentUserEmail = ""
            self.currentUserName = ""
            self.profilePictureURL = nil
            self.profileImage = nil
        }
        
        // Cancel any ongoing image load
        imageLoadTask?.cancel()
        
        print("User deleted successfully.")
    }

    // MARK: - Profile Picture Methods

    /// Loads the profile picture for the current user
    func loadProfilePicture(bypassCache: Bool = false) async {
        // Cancel any existing load task
        imageLoadTask?.cancel()
        
        // Prevent multiple simultaneous loads
        guard !isLoadingProfileImage else {
            print("⏳ Already loading profile picture, skipping...")
            return
        }
        
        print("🔄 loadProfilePicture called with bypassCache: \(bypassCache)")
        
        await MainActor.run {
            self.isLoadingProfileImage = true
        }
        
        defer {
            Task { @MainActor in
                print("🏁 loadProfilePicture finishing, setting isLoadingProfileImage = false")
                self.isLoadingProfileImage = false
            }
        }
        
        imageLoadTask = Task.detached(priority: .userInitiated) { [weak self] in
            do {
                guard let self = self else {
                    print("❌ Self is nil in imageLoadTask")
                    return
                }
                
                print("🔑 Getting auth token...")
                let token = try await self.getAuthToken()
                
                print("🔍 Loading profile picture from: \(Constants.API.baseURL + Constants.API.profilePicture)")
                print("   bypassCache: \(bypassCache)")
                
                // Perform network request on background thread
                let image = try await URLSession.getImage(
                    endpoint: Constants.API.profilePicture,
                    token: token,
                    bypassCache: bypassCache)
                
                // Check if task was cancelled
                guard !Task.isCancelled else {
                    print("🚫 Profile picture load cancelled")
                    return
                }
                
                print("✅ Image received from server")
                await MainActor.run {
                    self.profileImage = image
                    print("✅ Profile picture set in AuthViewModel")
                }
            } catch {
                guard !Task.isCancelled else {
                    print("🚫 Task cancelled during error handling")
                    return
                }
                
                print("❌ Error loading profile picture: \(error)")
                await MainActor.run {
                    self?.profileImage = nil
                }
            }
        }
        
        print("⏳ Awaiting imageLoadTask completion...")
        // Wait for the task to complete
        await imageLoadTask?.value
        print("✅ imageLoadTask completed")
    }

    // MARK: - Helper Methods

    /// Debug function to print bearer token and UID
    func printDebugInfo() async {
        do {
            let token = try await getAuthToken()
            let uid = self.getCurrentUserId() ?? "No UID"
            print("🔑 Bearer Token: \(token)")
            print("👤 User ID: \(uid)")
        } catch {
            print("❌ Error getting debug info: \(error.localizedDescription)")
        }
    }

    /// Gets the current user's ID
    func getCurrentUserId() -> String? {
        return self.auth.currentUser?.uid
    }

    /// Checks if there is a valid authenticated user
    func checkAuthentication() async {
        if let user = auth.currentUser {
            await MainActor.run {
                self.isAuthenticated = true
                self.isSecondState = false
            }
            await self.fetchUserInfo()
        } else {
            await MainActor.run {
                self.isAuthenticated = false
                self.isSecondState = true
                self.currentUserEmail = ""
                self.currentUserName = ""
                self.profilePictureURL = nil
                self.profileImage = nil
            }
        }
    }

    /// Gets the authentication token for the current user
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

    // MARK: - Private Methods

    func storeProfilePictureURL(imageUrl _: String) async throws {
        // Implementation commented out for now
    }

    func uploadProfilePicture(image: UIImage) async throws -> Bool {
        let token = try await getAuthToken()

        print("🔍 Checking if user has existing profile picture...")
        
        // Always use PUT to update - simpler logic
        // The backend will handle whether it's a new picture or update
        print("📤 Uploading/updating profile picture with PUT...")
        let response = try await URLSession.uploadImageUpdate(
            endpoint: Constants.API.profilePicture,
            token: token,
            image: image,
            responseType: ProfilePictureResponse.self)

        await MainActor.run {
            self.profilePictureURL = response.imageURL
        }

        print("✅ Profile picture uploaded/updated successfully")
        return true
    }

    private func fetchUserInfo() async {
        guard let currentUser = auth.currentUser else {
            print("No current user logged in.")
            return
        }

        do {
            let document = try await db.collection("users").document(currentUser.uid).getDocument()

            guard let data = document.data() else {
                print("No user data found for UID: \(currentUser.uid) at \(Date())")
                return
            }

            await MainActor.run {
                self.currentUserName = data["name"] as? String ?? ""
                self.currentUserEmail = data["email"] as? String ?? ""
                self.profilePictureURL = data["profilePictureURL"] as? String
                print("User info fetched: \(self.currentUserName), \(self.currentUserEmail) at \(Date())")
            }
        } catch {
            print("Error fetching user document for UID \(currentUser.uid) at \(Date()): \(error.localizedDescription)")
        }
    }
}
