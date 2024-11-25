//
//  ContentView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/24/24.
//

import SwiftUI

// MARK: - Main App Structure
struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainView(isLimitedAccess: false)
            } else if authViewModel.isLimitedAccess {
                MainView(isLimitedAccess: true)
            } else {
                AuthenticationFlow()
            }
        }
        .environmentObject(authViewModel)
    }
}

// MARK: - Authentication Flow
struct AuthenticationFlow: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false
    
    var body: some View {
        VStack {
            // Skip Button
            HStack {
                Spacer()
                Button("Skip") {
                    authViewModel.enableLimitedAccess()
                }
                .padding()
            }
            
            // Login Form
            LoginView()
            
            // Sign Up Navigation
            Button("Don't have an account? Sign up") {
                showSignUp = true
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

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

// MARK: - Main View Components
struct WeeklyOverviewSection: View {
    let isLimitedAccess: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Overview")
                .font(.title2)
                .bold()
            
            if isLimitedAccess {
                // Limited preview for non-authenticated users
                LimitedAccessPreview()
            } else {
                // Full weekly stats for authenticated users
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Text("Weekly Statistics/Charts")
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}


struct LimitedAccessPreview: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 100)
                .overlay(
                    Text("Preview Mode - Sign in to see full statistics")
                        .foregroundColor(.gray)
                )
            
            NavigationLink(destination: AuthenticationFlow()) {
                Text("Sign in to access all features")
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding(.top)
        }
    }
}


// MARK: - View Models
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLimitedAccess = false
    
    func enableLimitedAccess() {
        isLimitedAccess = true
        print("Limited access enabled") // Add debug print
    }
    
    func login(username: String, password: String) {
        // Add your login logic here
        isAuthenticated = true
        isLimitedAccess = false
    }
    
    func signOut() {
        isAuthenticated = false
        isLimitedAccess = false
    }
}

struct NotesFeedSection: View {
    let isLimitedAccess: Bool
    let notes = ["Note 1", "Note 2", "Note 3"] // Replace with data model
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Notes")
                .font(.title2)
                .bold()
            
            if isLimitedAccess {
                // Show limited preview for non-authenticated users
                VStack(spacing: 16) {
                    NoteCard(note: "Preview Note")
                        .opacity(0.7)
                    
                    Text("Sign in to see more notes and create your own")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                // Show full notes feed for authenticated users
                ForEach(notes, id: \.self) { note in
                    NoteCard(note: note)
                }
            }
        }
    }
}

struct NoteCard: View {
    let note: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(note)
                .font(.body)
            
            HStack {
                Text("Date")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                // Add any interaction buttons here
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Add Note View
struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var noteText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $noteText)
                    .padding()
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        // Add save logic here
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    var body: some View {
        VStack {
            // Profile Header
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                
                Text("User Name")
                    .font(.title2)
                
                Text("user@email.com")
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Profile Settings/Options
            List {
                Button("Edit Profile") {
                    // Add edit profile action
                }
                
                Button("Settings") {
                    // Add settings action
                }
                
                Button("Log Out", role: .destructive) {
                    // Add logout action
                }
            }
        }
        .navigationTitle("Profile")
    }
}

// MARK: - Auth Views (Login/SignUp remained the same)
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Login") {
                // Update login logic to use authViewModel
                authViewModel.login(username: username, password: password)
            }
        }
        .padding()
    }
}


struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Name", text: $viewModel.name)
                TextField("Email", text: $viewModel.email)
                SecureField("Password", text: $viewModel.password)
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                
                Button("Sign Up") {
                    viewModel.signUp()
                }
            }
            .padding()
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    
    func login() {
        // Implement login logic
    }
}

class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    func signUp() {
        // Implement sign up logic
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
