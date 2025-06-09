import PhotosUI
import SwiftUI

extension ProfileView {
    @MainActor class ViewModel: ObservableObject {
        // MARK: - Published Properties

        @Published var profileImage: UIImage?
        @Published var selectedImage: UIImage?
        @Published var selectedItem: PhotosPickerItem?
        @Published var showDeleteConfirmation = false
        @Published var showSuccessMessage = false
        @Published var errorMessage = ""

        // Profile Edit Properties
        @Published var newUsername = ""
        @Published var newEmail = ""
        @Published var newPassword = ""
        @Published var confirmPassword = ""

        // MARK: - Dependencies

        private let authViewModel: AuthViewModel
        private let notesViewModel: NotesViewModel

        // MARK: - Initialization

        init(authViewModel: AuthViewModel, notesViewModel: NotesViewModel) {
            self.authViewModel = authViewModel
            self.notesViewModel = notesViewModel
        }

        // MARK: - Profile Methods

        func loadProfilePicture() async {
            await self.authViewModel.fetchProfilePicture()
            if let urlString = authViewModel.profilePictureURL,
               let url = URL(string: urlString)
            {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        self.profileImage = image
                    }
                } catch {
                    print("Error loading profile picture: \(error)")
                }
            }
        }

        func handleImageSelection(_ newItem: PhotosPickerItem?) async {
            if let data = try? await newItem?.loadTransferable(type: Data.self),
               let image = UIImage(data: data)
            {
                self.selectedImage = image
                do {
                    let success = try await authViewModel.uploadProfilePicture(image: image)
                    if success {
                        await self.loadProfilePicture()
                    }
                } catch {
                    print("Error uploading image: \(error)")
                }
            }
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
