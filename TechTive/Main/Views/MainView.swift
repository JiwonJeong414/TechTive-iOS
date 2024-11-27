//
//  MainView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

// MARK: - Main View After Authentication
struct MainView: View {
    @StateObject private var notesViewModel = NotesViewModel() // State objects are more for reference types like classes
    @State private var showAddNote = false // states are for more primitive types
    let isLimitedAccess: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Overview Section
                    WeeklyOverviewSection(isLimitedAccess: isLimitedAccess)
                    
                    // Notes Feed
                    NotesFeedSection(viewModel: notesViewModel, isLimitedAccess: isLimitedAccess)
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
                AddNoteView(viewModel: notesViewModel, userId: "123")
            }
        }
    }
}

#Preview {
    MainView(isLimitedAccess: false)
}
