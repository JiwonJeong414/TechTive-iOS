//
//  ProfileViewModel.swift
//  TechTive
//
//  Profile view model
//

import PhotosUI
import SwiftUI

extension ProfileView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
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
            do {
                let image = try await NetworkManager.shared.getProfilePicture()
                
                await MainActor.run {
                    profileImage = image
                }
            } catch {
                print("Error loading profile picture: \(error)")
                await MainActor.run {
                    profileImage = nil
                }
            }
        }
        
        func checkAuthentication() async {
            await authViewModel.checkAuthentication()
        }
        
        func handleImageSelection(_ newItem: PhotosPickerItem?) async {
            if let data = try? await newItem?.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                do {
                    let response = try await NetworkManager.shared.uploadProfilePicture(image: image)
                    
                    if response.imageURL != nil {
                        await loadProfilePicture()
                        selectedImage = nil
                    }
                } catch {
                    print("Error uploading image: \(error)")
                    selectedImage = nil
                }
            }
        }
        
        // MARK: - Profile Edit Methods
        
        func handleSaveChanges() async {
            // Validate input fields
            if newPassword != confirmPassword {
                errorMessage = "Passwords do not match"
                return
            }
            if newEmail.isEmpty && newUsername.isEmpty && newPassword.isEmpty {
                errorMessage = "Please fill in at least one field"
                return
            }
            
            errorMessage = ""
            
            if !newUsername.isEmpty {
                let (_, error) = await authViewModel.updateUsername(newUsername: newUsername)
                if let error = error {
                    errorMessage = error
                    return
                }
            }
            
            if !newEmail.isEmpty {
                do {
                    try await authViewModel.updateEmail(newEmail: newEmail)
                } catch {
                    errorMessage = error.localizedDescription
                    return
                }
            }
            
            if !newPassword.isEmpty {
                do {
                    try await authViewModel.updatePassword(newPassword: newPassword)
                } catch {
                    errorMessage = error.localizedDescription
                    return
                }
            }
            
            showSuccessMessage = true
            resetFields()
        }
        
        func resetFields() {
            newUsername = ""
            newEmail = ""
            newPassword = ""
            confirmPassword = ""
            errorMessage = ""
        }
        
        func deleteAccount() async throws {
            try await authViewModel.deleteUser()
        }
        
        func signOut() {
            authViewModel.signOut()
        }
        
        // MARK: - Computed Properties
        
        var currentUserName: String {
            authViewModel.currentUserName
        }
        
        var currentUserEmail: String {
            authViewModel.currentUserEmail
        }
        
        var notesPerWeek: [(week: String, count: Int)] {
            notesViewModel.notesPerWeek()
        }
        
        var totalNotes: Int {
            notesViewModel.notes.count
        }
        
        var averageNotesPerWeek: Double {
            notesViewModel.notes.isEmpty ? 0 : Double(notesViewModel.notes.count) / 7.0
        }
        
        var longestStreak: Int {
            notesViewModel.calculateLongestStreak()
        }
        
        var isAuthenticated: Bool {
            authViewModel.isAuthenticated
        }
    }
}
