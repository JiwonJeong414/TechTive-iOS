import PhotosUI
import SwiftUI

extension ProfileView {
    @MainActor class ViewModel: ObservableObject {
        // MARK: - Published Properties

        // REMOVED: @Published var profileImage: UIImage?
        // Use authViewModel.profileImage as single source of truth
        
        @Published var selectedImage: UIImage?
        @Published var selectedItem: PhotosPickerItem?
        @Published var showDeleteConfirmation = false
        @Published var showSuccessMessage = false
        @Published var errorMessage = ""
        @Published var isUploadingImage = false

        // Profile Edit Properties
        @Published var newUsername = ""
        @Published var newEmail = ""
        @Published var newPassword = ""
        @Published var confirmPassword = ""

        // MARK: - Dependencies

        private let authViewModel: AuthViewModel
        private let notesViewModel: NotesViewModel
        
        private var uploadTask: Task<Void, Never>?

        // MARK: - Initialization

        init(authViewModel: AuthViewModel, notesViewModel: NotesViewModel) {
            self.authViewModel = authViewModel
            self.notesViewModel = notesViewModel
        }
        
        deinit {
            uploadTask?.cancel()
        }

        // MARK: - Profile Methods

        func loadProfilePicture() async {
            // Delegate to AuthViewModel - single source of truth
            await authViewModel.loadProfilePicture()
        }

        func checkAuthentication() async {
            await self.authViewModel.checkAuthentication()
        }

        func handleImageSelection(_ newItem: PhotosPickerItem?) async {
            guard let newItem = newItem else {
                // User cancelled selection
                print("ℹ️ Image selection cancelled")
                return
            }
            
            // Cancel any existing upload
            uploadTask?.cancel()
            
            // Don't await this task - let it run in background
            uploadTask = Task { @MainActor in
                print("📸 Starting image selection process...")
                
                // Try to load the image data
                guard let data = try? await newItem.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    print("❌ Failed to load image data")
                    return
                }
                
                print("✅ Image data loaded, showing preview")
                // Show selected image immediately for better UX
                self.selectedImage = image
                self.isUploadingImage = true
                
                defer {
                    // Always reset loading state when done
                    print("🔄 Resetting upload state")
                    self.isUploadingImage = false
                }
                
                do {
                    print("📤 Starting upload...")
                    let success = try await authViewModel.uploadProfilePicture(image: image)
                    
                    guard !Task.isCancelled else {
                        print("🚫 Upload cancelled")
                        self.selectedImage = nil
                        return
                    }
                    
                    if success {
                        print("✅ Upload successful, clearing selected image")
                        // Clear selected image - this will show the old cached image
                        self.selectedImage = nil
                        
                        print("⏰ Waiting 1 second before reload...")
                        // Longer delay to ensure server processed the upload
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        
                        print("🔄 Triggering profile picture reload in background...")
                        // DON'T await - launch in separate task to avoid blocking
                        Task.detached(priority: .userInitiated) { [weak self] in
                            guard let self = self else { return }
                            print("🔄 Background task: calling loadProfilePicture...")
                            await self.authViewModel.loadProfilePicture(bypassCache: true)
                            print("✅ Background task: loadProfilePicture completed")
                        }
                        print("✅ Reload triggered, continuing...")
                    } else {
                        print("❌ Upload returned false")
                        self.selectedImage = nil
                    }
                } catch {
                    guard !Task.isCancelled else {
                        print("🚫 Upload cancelled")
                        self.selectedImage = nil
                        return
                    }
                    print("❌ Error uploading image: \(error)")
                    self.selectedImage = nil
                }
            }
            
            // Don't await - let it complete in background
        }

        // MARK: - Profile Edit Methods

        func handleSaveChanges() async {
            // Validate input fields
            if self.newPassword != self.confirmPassword {
                self.errorMessage = "Passwords do not match"
                return
            }
            if self.newEmail.isEmpty && self.newUsername.isEmpty && self.newPassword.isEmpty {
                self.errorMessage = "Please fill in at least one field"
                return
            }

            self.errorMessage = ""

            // Update user information using AuthViewModel
            if !self.newUsername.isEmpty {
                let (_, error) = await authViewModel.updateUsername(newUsername: self.newUsername)
                if let error = error {
                    self.errorMessage = error
                    return
                }
            }

            if !self.newEmail.isEmpty {
                do {
                    try await self.authViewModel.updateEmail(newEmail: self.newEmail)
                } catch {
                    self.errorMessage = error.localizedDescription
                    return
                }
            }

            if !self.newPassword.isEmpty {
                do {
                    try await self.authViewModel.updatePassword(newPassword: self.newPassword)
                } catch {
                    self.errorMessage = error.localizedDescription
                    return
                }
            }

            // Show success message and reset fields
            self.showSuccessMessage = true
            self.resetFields()
        }

        func resetFields() {
            self.newUsername = ""
            self.newEmail = ""
            self.newPassword = ""
            self.confirmPassword = ""
            self.errorMessage = ""
        }

        func deleteAccount() async throws {
            try await self.authViewModel.deleteUser()
        }

        func signOut() {
            self.authViewModel.signOut()
        }

        // MARK: - Computed Properties
        
        var profileImage: UIImage? {
            // Read from AuthViewModel as single source of truth
            authViewModel.profileImage
        }
        
        var isLoadingImage: Bool {
            // Check if AuthViewModel is loading OR we're uploading
            authViewModel.isLoadingProfileImage || isUploadingImage
        }

        var currentUserName: String {
            self.authViewModel.currentUserName
        }

        var currentUserEmail: String {
            self.authViewModel.currentUserEmail
        }

        var notesPerWeek: [(week: String, count: Int)] {
            self.notesViewModel.notesPerWeek()
        }

        var totalNotes: Int {
            self.notesViewModel.notes.count
        }

        var averageNotesPerWeek: Double {
            self.notesViewModel.notes.isEmpty ? 0 : Double(self.notesViewModel.notes.count) / 7.0
        }

        var longestStreak: Int {
            self.notesViewModel.calculateLongestStreak()
        }

        var isAuthenticated: Bool {
            self.authViewModel.isAuthenticated
        }
    }
}
