//
//  ProfileView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

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
                Image(systemName: "rectangle").fixedSize()
                Button("calendar instances"){
                    
                }
            }
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView()
}
