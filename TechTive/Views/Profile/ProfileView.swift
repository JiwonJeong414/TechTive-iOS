import Charts
import SwiftUI

// MARK: - Profile View

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel

    @State private var profileImage: UIImage?

    @Environment(\.dismiss) var dismiss

    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showDeleteConfirmation = false

    private let buttonColor = Color(Constants.Colors.lightYellow)
    private let purpleColor = Color(Constants.Colors.purple)

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

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Profile Header Section with Purple Background
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
                        // Back button aligned to the left
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
                        .padding(.horizontal)

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

                            // Edit Button
                            Button(action: {
                                self.showImagePicker = true
                            }) {
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
                            .offset(x: 8, y: 8)
                        }
                        .sheet(isPresented: self.$showImagePicker) {
                            ImagePicker(
                                selectedImage: self.$selectedImage,
                                authViewModel: self.authViewModel)
                            { success in
                                if success {
                                    // Refresh the profile picture
                                    self.loadProfilePicture()
                                }
                            }
                        }

                        Text(self.authViewModel.currentUserName)
                            .font(.custom("Poppins-Medium", fixedSize: 24))
                            .foregroundColor(Color(Constants.Colors.darkPurple))

                        Text(self.authViewModel.currentUserEmail)
                            .font(.custom("Poppins-Medium", fixedSize: 16))
                            .foregroundColor(Color(Constants.Colors.darkPurple))
                            .padding(.bottom, 32)
                    }
                    .padding(.horizontal)
                }
                .frame(height: 300)

                // Yellow Background Section
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
                        // Profile Settings/Options
                        VStack(spacing: 0) {
                            HStack {
                                NavigationLink(destination: ProfileEditView().environmentObject(self.authViewModel)
                                    .environmentObject(self.notesViewModel))
                                {
                                    Text("Edit Profile")
                                        .foregroundColor(.black)
                                        .font(.custom("CourierPrime-Regular", fixedSize: 16))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(self.buttonColor)

                            Divider()
                                .background(Color.orange)

                            // Logout Button
                            Button(action: {
                                self.authViewModel.signOut()
                            }) {
                                HStack {
                                    Text("Logout")
                                        .foregroundColor(.black)
                                        .font(.custom("CourierPrime-Regular", fixedSize: 16))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(self.buttonColor)
                            }

                            Divider()
                                .background(Color.orange)

                            // Settings Button
                            Button(action: {
                                self.showDeleteConfirmation = true
                            }) {
                                HStack {
                                    Text("Delete Account")
                                        .foregroundColor(.red)
                                        .font(.custom("CourierPrime-Regular", fixedSize: 16))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(self.buttonColor)
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
                        .padding(.horizontal)
                        .background(self.buttonColor)
                        .cornerRadius(8)
                        .frame(width: 380)
                        .padding(.top, 60)
                        .padding(.bottom, 15)

                        // Stats Section
                        VStack(alignment: .leading, spacing: 16) {
                            // Your existing stats section code remains the same
                            Divider()

                            Text("MY STATS")
                                .font(.custom("Poppins-SemiBold", fixedSize: 20))
                                .padding(.leading)

                            // Graph Section
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

                            // Stats Cards
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "Total Notes",
                                    value: "\(self.notesViewModel.notes.count)")

                                StatCard(
                                    title: "Average Notes/Week",
                                    value: String(
                                        format: "%.1f",
                                        self.notesViewModel.notes
                                            .isEmpty ? 0 : Double(self.notesViewModel.notes.count) / 7.0))

                                StatCard(
                                    title: "Longest Streak",
                                    value: "\(self.notesViewModel.calculateLongestStreak()) Weeks")
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
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
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(self.title)
                .font(.custom("Poppins-Regular", fixedSize: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)

            Text(self.value)
                .font(.custom("Poppins-SemiBold", fixedSize: 20))
                .foregroundColor(.orange)
        }
        .frame(width: 110, height: 110)
        .background(Color.yellow.opacity(0.4))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(NotesViewModel())
}
