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
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Spacer().frame(height: 40)
            
            // Title
            Text("Edit Profile")
                .font(.custom("Poppins-SemiBold", fixedSize: 32))
                .foregroundColor(Color(UIColor.color.darkPurple))
                .padding(.bottom, 20)
            
            // Form
            VStack(spacing: 20) {
                // Username Field
                TextField("Change Username", text: $newUsername)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .font(.custom("Poppins-Regular", size: 16))
                    .padding(.horizontal,20)
                // Email Field
                TextField("Change Email", text: $newEmail)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .font(.custom("Poppins-Regular", size: 16))
                    .keyboardType(.emailAddress)
                    .padding(.horizontal,20)
                
                // Password Field
                SecureField("Change Password", text: $newPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .font(.custom("Poppins-Regular", size: 16))
                    .padding(.horizontal,20)
                
                // Confirm Password Field
                SecureField("Confirm New Password", text: $confirmPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .font(.custom("Poppins-Regular", size: 16))
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
                    Task {
                        await handleSaveChanges()
                    }
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.custom("CourierPrime-Regular", fixedSize: 16))
                        .background(Color(hex: "E65100"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Cancel Button
                
                Button(action: {
                    resetFields()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.custom("CourierPrime-Regular", fixedSize: 16))
                        .background(Color(hex: "F3E5F5"))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.orange)
                        Text("Back") // Back label
                            .font(.custom("Poppins-Medium", fixedSize: 16))
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
    
    private func handleSaveChanges() async {
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
            let (_, error) = await authViewModel.updateUsername(newUsername: newUsername)
            if let error = error {
                errorMessage = error
                return
            }
        }

        if !newEmail.isEmpty {
            do {
                try await authViewModel.updateEmail(newEmail: newEmail)
            } catch {
                errorMessage = error.localizedDescription
                return
            }
        }

        if !newPassword.isEmpty {
            do {
                try await authViewModel.updatePassword(newPassword: newPassword)
            } catch {
                errorMessage = error.localizedDescription
                return
            }
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
        .environmentObject(NotesViewModel())
}
