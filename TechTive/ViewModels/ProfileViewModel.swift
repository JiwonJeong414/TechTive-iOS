//
//  ProfileViewModel.swift
//  TechTive
//
//  Fixed with proper logout and crash prevention
//

import PhotosUI
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var profileImage: UIImage?
    @Published var isLoadingImage = false
    @Published var showDeleteConfirmation = false
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
            _ = try await NetworkManager.shared.uploadProfilePicture(image: image)
            print("Profile picture uploaded successfully")
            await loadProfilePicture()
        } catch {
            print("Error uploading profile picture: \(error)")
        }
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
    
    // MARK: - Stats Computed Properties (with safety checks)
    
    var notesPerWeek: [(week: String, count: Int)] {
        // Safely access notes with a check
        guard !notesViewModel.notes.isEmpty else {
            return []
        }
        return notesViewModel.notesPerWeek()
    }
    
    var totalNotes: Int {
        notesViewModel.notes.count
    }
    
    var averageNotesPerWeek: Double {
        notesViewModel.notes.isEmpty ? 0 : Double(notesViewModel.notes.count) / 7.0
    }
    
    var longestStreak: Int {
        guard !notesViewModel.notes.isEmpty else {
            return 0
        }
        return notesViewModel.calculateLongestStreak()
    }
}
