import Charts
import PhotosUI
import SwiftUI

/// Profile View for TechTive
struct ProfileView: View {
    // MARK: - Properties

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @Environment(\.dismiss) var dismiss

    @State private var profileImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showDeleteConfirmation = false

    private let buttonColor = Color(Constants.Colors.lightYellow)
    private let purpleColor = Color(Constants.Colors.purple)

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
        .onAppear {
            self.loadProfilePicture()
        }
        .onChange(of: self.authViewModel.isAuthenticated) { isAuthenticated in
            if !isAuthenticated {
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
                print("Dismiss tapped")
                self.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.orange)
                    Text("Back")
                        .font(.custom("Poppins-Medium", fixedSize: 16))
                        .foregroundColor(.orange)
                }.padding(.top, 70)
            }
            Spacer()
        }
        .padding(.top, 30)
    }

    private var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
            } else if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 160, height: 160)
                    .foregroundColor(.gray)
            }

            PhotosPicker(selection: self.$selectedItem, matching: .images) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 4)

                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.orange)
                }
            }
            .onChange(of: self.selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data)
                    {
                        selectedImage = image
                        do {
                            let success = try await authViewModel.uploadProfilePicture(image: image)
                            if success {
                                self.loadProfilePicture()
                            }
                        } catch {
                            print("Error uploading image: \(error)")
                        }
                    }
                }
            }
        }
        .offset(x: 8, y: 8)
    }

    private var userInfoSection: some View {
        VStack {
            Text(self.authViewModel.currentUserName)
                .font(.custom("Poppins-Medium", fixedSize: 24))
                .foregroundColor(Color(Constants.Colors.darkPurple))

            Text(self.authViewModel.currentUserEmail)
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
            NavigationLink(destination: ProfileEditView()
                .environmentObject(self.authViewModel)
                .environmentObject(self.notesViewModel))
            {
                self.settingsButtonRow(title: "Edit Profile")
            }

            Divider().background(Color.orange)

            Button(action: {
                self.authViewModel.signOut()
            }) {
                self.settingsButtonRow(title: "Logout")
            }

            Divider().background(Color.orange)

            Button(action: {
                self.showDeleteConfirmation = true
            }) {
                self.settingsButtonRow(title: "Delete Account", isDestructive: true)
            }
            .alert("Are you sure?", isPresented: self.$showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        do {
                            try await self.authViewModel.deleteUser()
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
                .foregroundColor(isDestructive ? .red : .black)
                .font(.custom("CourierPrime-Regular", fixedSize: 16))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.orange)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(self.buttonColor)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()

            Text("MY STATS")
                .font(.custom("Poppins-SemiBold", fixedSize: 20))
                .padding(.leading)

            self.notesChartSection
            self.statsCardsSection
        }
    }

    private var notesChartSection: some View {
        VStack(spacing: 8) {
            Text("Notes Last 5 Weeks")
                .font(.custom("Poppins-Medium", fixedSize: 16))
                .foregroundColor(.black)

            Chart {
                ForEach(self.notesViewModel.notesPerWeek(), id: \.week) { data in
                    BarMark(
                        x: .value("Week", data.week),
                        y: .value("Count", data.count))
                        .foregroundStyle(Color.orange)
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
                value: "\(self.notesViewModel.notes.count)")

            StatCard(
                title: "Average Notes/Week",
                value: String(
                    format: "%.1f",
                    self.notesViewModel.notes.isEmpty ? 0 : Double(self.notesViewModel.notes.count) / 7.0))

            StatCard(
                title: "Longest Streak",
                value: "\(self.notesViewModel.calculateLongestStreak()) Weeks")
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Methods

    private func loadProfilePicture() {
        Task {
            await self.authViewModel.fetchProfilePicture()
            if let urlString = authViewModel.profilePictureURL,
               let url = URL(string: urlString)
            {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileImage = image
                        }
                    }
                } catch {
                    print("Error loading profile picture: \(error)")
                }
            }
        }
    }
}
