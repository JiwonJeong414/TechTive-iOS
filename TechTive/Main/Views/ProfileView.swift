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
        VStack(spacing: 0) {
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
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundColor(.black)

                    Text(authViewModel.currentUserEmail)
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundColor(.gray)
                }
                .padding()
            }

            // Profile Settings/Options
            ZStack{
                Color(UIColor.color.lightYellow).opacity(0.3)
                    .frame(maxWidth: .infinity, maxHeight: 550)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Button(action: {
                        // Add edit profile action
                    }) {
                        HStack {
                            NavigationLink(destination: ProfileEditView().environmentObject(authViewModel).environmentObject(notesViewModel)){
                            Text("Edit Profile")
                                .foregroundColor(.black)
                                .font(.custom("Poppins-Medium", size: 16))
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
                                .font(.custom("Poppins-Medium", size: 16))
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
                                .font(.custom("Poppins-Medium", size: 16))
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

            VStack(alignment: .leading, spacing: 16) {
                Text("MY STATS")
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .padding(.leading)

                // Graph Section
                VStack(spacing: 8) {
                    Text("Notes Last 5 Weeks")
                        .font(.custom("Poppins-Medium", size: 16))
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
                .frame(height: 240)
                .background(Color.yellow.opacity(0.4))
                .cornerRadius(12)
                .padding(.horizontal)

                // Stats Buttons Section
                HStack(spacing: 16) {
                    // Button 1: Total Notes
                    StatCard(
                        title: "Total Notes",
                        value: "\(notesViewModel.notes.count)"
                    )

                    // Button 2: Average Notes/Week
                    StatCard(
                        title: "Average Notes/Week",
                        value: String(format: "%.1f", notesViewModel.notes.isEmpty ? 0 : Double(notesViewModel.notes.count) / 7.0)

                    )

                    // Button 3: Longest Streak
                    StatCard(
                        title: "Longest Streak",
                        value: "3 Weeks"
                    )
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.color.lightYellow).opacity(0.3))
        }
        .navigationTitle("Profile")
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
            
            Text(value)
                .font(.custom("Poppins-SemiBold", size: 20))
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
