//
//  ProfileView.swift
//  TechTive
//
//  Rebuilt from scratch with proper state management
//

import Charts
import PhotosUI
import SwiftUI

struct ProfileView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProfileViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    
    // MARK: - Initialization
    
    init(authViewModel: AuthViewModel, notesViewModel: NotesViewModel) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(
            authViewModel: authViewModel,
            notesViewModel: notesViewModel
        ))
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileHeader
                profileContent
            }
        }
        .background(Color(Constants.Colors.backgroundColor))
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all, edges: .top)
        .task {
            await viewModel.loadProfilePicture()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            handlePhotoSelection(newItem)
        }
    }
    
    // MARK: - Header Section
    
    private var profileHeader: some View {
        ZStack {
            Color(Constants.Colors.purple)
                .frame(height: 300)
            
            VStack(spacing: 16) {
                backButton
                profileImageView
                userInfoView
            }
            .padding(.horizontal)
        }
        .frame(height: 300)
    }
    
    private var backButton: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                        .font(Constants.Fonts.poppinsMedium16)
                }
                .foregroundColor(Color(Constants.Colors.orange))
            }
            .padding(.top, 100)
            
            Spacer()
        }
    }
    
    private var profileImageView: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if isLoadingPhoto {
                    ProgressView()
                        .frame(width: 160, height: 160)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                } else if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 160, height: 160)
                        .foregroundColor(Color(Constants.Colors.gray))
                }
            }
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 4)
                    
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(Constants.Colors.profileOrange))
                }
            }
            .disabled(isLoadingPhoto || viewModel.isProcessing)
        }
    }
    
    private var userInfoView: some View {
        VStack(spacing: 4) {
            Text(viewModel.currentUserName)
                .font(Constants.Fonts.poppinsMedium24)
                .foregroundColor(Color(Constants.Colors.darkPurple))
            
            Text(viewModel.currentUserEmail)
                .font(Constants.Fonts.poppinsMedium16)
                .foregroundColor(Color(Constants.Colors.darkPurple))
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Content Section
    
    private var profileContent: some View {
        VStack(spacing: 16) {
            settingsSection
            statsSection
        }
        .padding(.top, 60)
    }
    
    private var settingsSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: ProfileEditView(viewModel: viewModel)) {
                settingsRow(title: "Edit Profile")
            }
            
            Divider().background(Color(Constants.Colors.orange))
            
            Button(action: { viewModel.signOut() }) {
                settingsRow(title: "Logout")
            }
            
            Divider().background(Color(Constants.Colors.orange))
            
            Button(action: { viewModel.showDeleteConfirmation = true }) {
                settingsRow(title: "Delete Account", isDestructive: true)
            }
        }
        .background(Color(Constants.Colors.lightYellow))
        .cornerRadius(8)
        .frame(width: 380)
        .padding(.horizontal)
        .alert("Are you sure?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteAccount()
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private func settingsRow(title: String, isDestructive: Bool = false) -> some View {
        HStack {
            Text(title)
                .foregroundColor(isDestructive ? Color(Constants.Colors.orange) : Color(Constants.Colors.black))
                .font(Constants.Fonts.courierPrime16)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(Constants.Colors.orange))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(Constants.Colors.lightYellow))
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            Text("MY STATS")
                .font(Constants.Fonts.poppinsSemiBold20)
                .padding(.leading)
            
            notesChart
            statsCards
        }
    }
    
    private var notesChart: some View {
        VStack(spacing: 8) {
            Text("Notes Last 5 Weeks")
                .font(Constants.Fonts.poppinsMedium16)
                .foregroundColor(Color(Constants.Colors.black))
            
            Chart {
                ForEach(viewModel.notesPerWeek, id: \.week) { data in
                    BarMark(
                        x: .value("Week", data.week),
                        y: .value("Count", data.count)
                    )
                    .foregroundStyle(Color(Constants.Colors.orange))
                }
            }
            .frame(height: 200)
            .padding(.horizontal, 4)
        }
        .frame(height: 240)
        .background(Color.yellow.opacity(0.4))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var statsCards: some View {
        HStack(spacing: 16) {
            StatCard(title: "Total Notes", value: "\(viewModel.totalNotes)")
            StatCard(title: "Average Notes/Week", value: String(format: "%.1f", viewModel.averageNotesPerWeek))
            StatCard(title: "Longest Streak", value: "\(viewModel.longestStreak) Weeks")
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Photo Handling
    
    private func handlePhotoSelection(_ item: PhotosPickerItem) {
        isLoadingPhoto = true
        
        Task {
            defer {
                Task { @MainActor in
                    isLoadingPhoto = false
                    selectedPhotoItem = nil
                }
            }
            
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                return
            }
            
            await viewModel.uploadProfilePicture(image)
        }
    }
}
