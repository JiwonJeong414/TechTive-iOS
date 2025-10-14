//
//  ProfileViewModel.swift
//  TechTive
//
//  Rebuilt from scratch with proper thread safety
//

import PhotosUI
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var profileImage: UIImage?
    @Published var isLoadingImage = false
    @Published var showDeleteConfirmation = false
    @Published var showSuccessMessage = false
    @Published var errorMessage = ""
    
    // Edit form state
    @Published var newUsername = ""
    @Published var newEmail = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isProcessing = false
    
    // MARK: - Dependencies
    
    private let authViewModel: AuthViewModel
    private let notesViewModel: NotesViewModel
    
    // MARK: - Initialization
    
    init(authViewModel: AuthViewModel, notesViewModel: NotesViewModel) {
        self.authViewModel = authViewModel
        self.notesViewModel = notesViewModel
    }
    
    // MARK: - Profile Picture Methods
    
    func loadProfilePicture() async {
        guard !isLoadingImage else { return }
        
        isLoadingImage = true
        defer { isLoadingImage = false }
        
        do {
            let image = try await NetworkManager.shared.getProfilePicture()
            profileImage = image
        } catch {
            print("Error loading profile picture: \(error)")
            profileImage = nil
        }
    }
    
    func uploadProfilePicture(_ image: UIImage) async {
        guard !isProcessing else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            // Single call - backend handles create or update automatically
            _ = try await NetworkManager.shared.uploadProfilePicture(image: image)
            
            print("Profile picture uploaded successfully")
            
            // Reload after successful upload
            await loadProfilePicture()
            
        } catch {
            print("Error uploading profile picture: \(error)")
            errorMessage = "Failed to upload profile picture"
        }
    }
    
    // MARK: - Profile Edit Methods
    
    func saveProfileChanges() async -> Bool {
        guard !isProcessing else { return false }
        
        // Validate
        if newPassword != confirmPassword {
            errorMessage = "Passwords do not match"
            return false
        }
        
        if newEmail.isEmpty && newUsername.isEmpty && newPassword.isEmpty {
            errorMessage = "Please fill in at least one field"
            return false
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        errorMessage = ""
        
        // Update username
        if !newUsername.isEmpty {
            let (success, error) = await authViewModel.updateUsername(newUsername: newUsername)
            if !success, let error = error {
                errorMessage = error
                return false
            }
        }
        
        // Update email
        if !newEmail.isEmpty {
            do {
                try await authViewModel.updateEmail(newEmail: newEmail)
            } catch {
                errorMessage = error.localizedDescription
                return false
            }
        }
        
        // Update password
        if !newPassword.isEmpty {
            do {
                try await authViewModel.updatePassword(newPassword: newPassword)
            } catch {
                errorMessage = error.localizedDescription
                return false
            }
        }
        
        resetForm()
        showSuccessMessage = true
        return true
    }
    
    func resetForm() {
        newUsername = ""
        newEmail = ""
        newPassword = ""
        confirmPassword = ""
        errorMessage = ""
    }
    
    // MARK: - Account Actions
    
    func deleteAccount() async throws {
        guard !isProcessing else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        
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
    
    var isAuthenticated: Bool {
        authViewModel.isAuthenticated
    }
    
    // MARK: - Stats Computed Properties
    
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
}
