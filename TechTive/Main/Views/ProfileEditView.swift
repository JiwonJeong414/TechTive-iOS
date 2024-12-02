//
//  ProfileEditView.swift
//  TechTive
//
//  Created by Keya Aggarwal on 02/12/24.
//


import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @State private var newUsername: String = ""
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showSuccessMessage: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            Spacer().frame(height: 40)

            // Title
            Text("Edit Profile")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(UIColor.color.darkPurple))
                .padding(.bottom, 20)

            // Form
            VStack(spacing: 20) {
                // Username Field
                TextField("Change Username", text: $newUsername)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal,20)
                // Email Field
                TextField("Change Email", text: $newEmail)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal,20)

                // Password Field
                SecureField("Change Password", text: $newPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal,20)

                // Confirm Password Field
                SecureField("Confirm New Password", text: $confirmPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal,20)
            }

            // Error Message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }

            // Buttons
            HStack(spacing: 20) {
                // Save Changes Button
                Button(action: {
                    handleSaveChanges()
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "E65100"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Cancel Button
                
                    Button(action: {
                        resetFields()
                    }) {
                        NavigationLink(destination: ProfileView().environmentObject(self.notesViewModel).environmentObject(self.authViewModel)) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "F3E5F5"))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()
        }
        .background(Color(UIColor.color.backgroundColor).ignoresSafeArea())
        .alert(isPresented: $showSuccessMessage) {
            Alert(title: Text("Success"), message: Text("Profile updated successfully!"), dismissButton: .default(Text("OK")))
        }
    }

    private func handleSaveChanges() {
        // Validate input fields
        if newPassword != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }
        if newEmail.isEmpty && newUsername.isEmpty && newPassword.isEmpty {
            errorMessage = "Please fill in at least one field"
            return
        }

        errorMessage = ""

        // Update user information using AuthViewModel
        if !newUsername.isEmpty {
            authViewModel.updateUsername(newUsername: newUsername) { success, error in
                if let error = error {
                    self.errorMessage = error
                }
            }
        }
        if !newEmail.isEmpty {
            authViewModel.updateEmail(newEmail: newEmail)
        }
        if !newPassword.isEmpty {
            authViewModel.updatePassword(newPassword: newPassword)
        }

        // Show success message and reset fields
        showSuccessMessage = true
        resetFields()
    }

    private func resetFields() {
        newUsername = ""
        newEmail = ""
        newPassword = ""
        confirmPassword = ""
        errorMessage = ""
    }
}
#Preview {
    ProfileEditView()
        .environmentObject(AuthViewModel())
}
