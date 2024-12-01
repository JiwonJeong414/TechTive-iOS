//
//  ProfileView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    private let buttonColor = Color(UIColor.color.lightYellow)
    
    var body: some View {
        VStack(spacing: 0) { // Use zero spacing between the VStack elements
            // Profile Header
            ZStack{
                Color.purple.opacity(0.1)
                    .frame(maxWidth: .infinity, maxHeight: 500)
                    .ignoresSafeArea()

                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)

                    Text("USERNAME")
                        .font(.headline)
                        .foregroundColor(.black)

                    Text("user@email.com")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            }

            // Profile Settings/Options
            ZStack{
                Color(UIColor.color.lightYellow).opacity(0.3)
                    .frame(maxWidth: .infinity, maxHeight: 550)
                    .ignoresSafeArea()

                VStack(spacing: 0) { // Remove spacing between the buttons
                    Button(action: {
                        // Add edit profile action
                    }) {
                        HStack {
                            Text("Edit Profile")
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(buttonColor)
                    }

                    Divider() // Divider between buttons
                        .background(Color.orange)

                    Button(action: {
                        // Add settings action
                    }) {
                        HStack {
                            Text("Settings")
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(buttonColor)
                    }

                    Divider() // Divider between buttons
                        .background(Color.orange)

                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Text("Logout")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(buttonColor)
                    }
                }
                .padding(.horizontal)
                .background(buttonColor)
                .cornerRadius(8)
                .frame(width: 380)
            }

            // Stats Section
            VStack(alignment: .leading) {
                Text("MY STATS")
                    .font(.headline)
                    .padding(.leading)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(Color.yellow.opacity(0.4))
                            .frame(height: 100)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.color.lightYellow).opacity(0.3))
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
