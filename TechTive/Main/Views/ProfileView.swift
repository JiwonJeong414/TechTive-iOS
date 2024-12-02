//
//  ProfileView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI
import Charts

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel

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

                    Text(authViewModel.currentUserName)
                        .font(.headline)
                        .foregroundColor(.black)

                    Text(authViewModel.currentUserEmail)
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
                            NavigationLink(destination: ProfileEditView()){
                            Text("Edit Profile")
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.orange)
                        }
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
            // Stats Section
            VStack(alignment: .leading) {
                Text("MY STATS")
                    .font(.headline)
                    .padding(.leading)

                // Graph Section
                VStack {
                    Text("Notes Last 5 Weeks")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    Chart {
                        ForEach(notesViewModel.notesPerWeek(), id: \.week) { data in
                            BarMark(
                                x: .value("Week", data.week),
                                y: .value("Count", data.count)
                            )
                            .foregroundStyle(Color.orange)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal, 4)
                }
                .frame(height: 220)
                .background(Color.yellow.opacity(0.4))
                .cornerRadius(12)
                .padding(.horizontal)

                // Stats Buttons Section
                HStack(spacing: 16) {
                    // Button 1: Total Notes
                    VStack {
                        Text("Total Notes")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("\(notesViewModel.notes.count)")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.yellow.opacity(0.4))
                    .cornerRadius(12)

                    // Button 2: Average Notes/Week
                    VStack {
                        Text("Average Notes/Week")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        let avg = notesViewModel.notes.isEmpty ? 0 : notesViewModel.notes.count / 5
                        Text("\(avg)")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.yellow.opacity(0.4))
                    .cornerRadius(12)

                    // Button 3: Longest Streak
                    VStack {
                        Text("Longest Streak")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("3 Weeks") // Replace with dynamic logic if needed
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.yellow.opacity(0.4))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.color.lightYellow).opacity(0.3))

        }
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(NotesViewModel())
}
