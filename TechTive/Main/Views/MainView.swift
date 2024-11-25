//
//  MainView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

// MARK: - Main View After Authentication
struct MainView: View {
    @State private var showAddNote = false
    let isLimitedAccess: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Overview Section
                    WeeklyOverviewSection(isLimitedAccess: isLimitedAccess)
                    
                    // Notes Feed
                    NotesFeedSection(isLimitedAccess: isLimitedAccess)
                }
                .padding()
            }
            .navigationTitle("Your Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isLimitedAccess {
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle")
                                .font(.title2)
                        }
                    } else {
                        // Show login button for limited access users
                        NavigationLink(destination: AuthenticationFlow()) {
                            Text("Login")
                                .bold()
                        }
                    }
                }
            }
            // Floating Action Button for adding notes (only for authenticated users)
            .overlay(
                Group {
                    if !isLimitedAccess {
                        Button(action: {
                            showAddNote = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 56))
                                .foregroundColor(.blue)
                                .shadow(radius: 3)
                        }
                        .padding()
                        .offset(x: UIScreen.main.bounds.width/2 - 60, y: UIScreen.main.bounds.height/2 - 120)
                    }
                }
            )
            .sheet(isPresented: $showAddNote) {
                AddNoteView()
            }
        }
    }
}

#Preview {
    MainView(isLimitedAccess: false)
}
