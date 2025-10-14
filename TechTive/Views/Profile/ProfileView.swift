import Charts
import PhotosUI
import SwiftUI

/// Profile View for TechTive
struct ProfileView: View {
    // MARK: - Properties

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ViewModel

    private let buttonColor = Color(Constants.Colors.lightYellow)
    private let purpleColor = Color(Constants.Colors.purple)

    init(authViewModel: AuthViewModel, notesViewModel: NotesViewModel) {
        _viewModel = StateObject(wrappedValue: ViewModel(
            authViewModel: authViewModel,
            notesViewModel: notesViewModel))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                self.profileHeaderSection
                self.profileContentSection
            }
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all, edges: .top)
        .task {
            // Use .task instead of .onAppear for better async handling
            await self.viewModel.checkAuthentication()
            if !self.viewModel.isAuthenticated {
                self.dismiss()
                return
            }
            // Load profile picture
            await self.viewModel.loadProfilePicture()
        }
        .onChange(of: self.viewModel.isAuthenticated) { oldValue, newValue in
            // ✅ Fixed: Added oldValue parameter
            if !newValue {
                self.dismiss()
            }
        }
    }

    // MARK: - Components

    private var profileHeaderSection: some View {
        ZStack {
            GeometryReader { geometry in
                self.purpleColor
                    .frame(
                        width: geometry.size.width,
                        height: max(0, geometry.size.height + geometry.frame(in: .global).minY))
                    .offset(y: -geometry.frame(in: .global).minY)
                    .allowsHitTesting(false)
            }

            VStack {
                self.backButton
                self.profileImageSection
                self.userInfoSection
            }
            .padding(.horizontal)
        }
        .frame(height: 300)
    }

    private var backButton: some View {
        HStack {
            Button(action: {
                self.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(Constants.Colors.orange))
                    Text("Back")
                        .font(.custom("Poppins-Medium", fixedSize: 16))
                        .foregroundColor(Color(Constants.Colors.orange))
                }.padding(.top, 70)
            }
            Spacer()
        }
        .padding(.top, 30)
    }

    private var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            // Show selected image with highest priority (immediate feedback)
            if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
            }
            // Show profile image (single source of truth)
            else if let profileImage = viewModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
            }
            // Default placeholder
            else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 160, height: 160)
                    .foregroundColor(Color(Constants.Colors.gray))
            }

            PhotosPicker(selection: self.$viewModel.selectedItem, matching: .images) {
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
            .onChange(of: self.viewModel.selectedItem) { oldValue, newItem in
                // ✅ Fixed: Added oldValue parameter
                Task {
                    await self.viewModel.handleImageSelection(newItem)
                }
            }
        }
        .offset(x: 8, y: 8)
    }

    private var userInfoSection: some View {
        VStack {
            Text(self.viewModel.currentUserName)
                .font(.custom("Poppins-Medium", fixedSize: 24))
                .foregroundColor(Color(Constants.Colors.darkPurple))

            Text(self.viewModel.currentUserEmail)
                .font(.custom("Poppins-Medium", fixedSize: 16))
                .foregroundColor(Color(Constants.Colors.darkPurple))
                .padding(.bottom, 32)
        }
    }

    private var profileContentSection: some View {
        ZStack {
            GeometryReader { geometry in
                Color(Constants.Colors.lightYellow).opacity(0)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height + geometry.frame(in: .global).minY)
                    .offset(y: -geometry.frame(in: .global).minY)
                    .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                self.profileSettingsSection
                self.statsSection
            }
        }
    }

    private var profileSettingsSection: some View {
        VStack(spacing: 0) {
            self.profileSettingsButtons
        }
        .padding(.horizontal)
        .background(self.buttonColor)
        .cornerRadius(8)
        .frame(width: 380)
        .padding(.top, 60)
        .padding(.bottom, 15)
    }

    private var profileSettingsButtons: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: ProfileEditView(viewModel: self.viewModel)) {
                self.settingsButtonRow(title: "Edit Profile")
            }

            Divider().background(Color.orange)

            Button(action: {
                self.viewModel.signOut()
            }) {
                self.settingsButtonRow(title: "Logout")
            }

            Divider().background(Color.orange)

            Button(action: {
                self.viewModel.showDeleteConfirmation = true
            }) {
                self.settingsButtonRow(title: "Delete Account", isDestructive: true)
            }
            .alert("Are you sure?", isPresented: self.$viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        do {
                            try await self.viewModel.deleteAccount()
                        } catch {
                            print("delete account error")
                        }
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func settingsButtonRow(title: String, isDestructive: Bool = false) -> some View {
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
        .background(self.buttonColor)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()

            Text("MY STATS")
                .font(Constants.Fonts.poppinsSemiBold20)
                .padding(.leading)

            self.notesChartSection
            self.statsCardsSection
        }
    }

    private var notesChartSection: some View {
        VStack(spacing: 8) {
            Text("Notes Last 5 Weeks")
                .font(Constants.Fonts.poppinsMedium16)
                .foregroundColor(Color(Constants.Colors.black))

            Chart {
                ForEach(self.viewModel.notesPerWeek, id: \.week) { data in
                    BarMark(
                        x: .value("Week", data.week),
                        y: .value("Count", data.count))
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

    private var statsCardsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Notes",
                value: "\(self.viewModel.totalNotes)")

            StatCard(
                title: "Average Notes/Week",
                value: String(format: "%.1f", self.viewModel.averageNotesPerWeek))

            StatCard(
                title: "Longest Streak",
                value: "\(self.viewModel.longestStreak) Weeks")
        }
        .padding(.horizontal, 20)
    }
}
