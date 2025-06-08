import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @State private var newUsername = ""
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showSuccessMessage = false
    @State private var errorMessage = ""

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
                TextField("Change Username", text: self.$newUsername)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .font(.custom("Poppins-Regular", size: 16))
                    .padding(.horizontal, 20)
                // Email Field
                TextField("Change Email", text: self.$newEmail)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .font(.custom("Poppins-Regular", size: 16))
                    .keyboardType(.emailAddress)
                    .padding(.horizontal, 20)

                // Password Field
                SecureField("Change Password", text: self.$newPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .font(.custom("Poppins-Regular", size: 16))
                    .padding(.horizontal, 20)

                // Confirm Password Field
                SecureField("Confirm New Password", text: self.$confirmPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .font(.custom("Poppins-Regular", size: 16))
                    .padding(.horizontal, 20)
            }

            // Error Message
            if !self.errorMessage.isEmpty {
                Text(self.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }

            // Buttons
            HStack(spacing: 20) {
                // Save Changes Button
                Button(action: {
                    Task {
                        await self.handleSaveChanges()
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
                    self.resetFields()
                    self.presentationMode.wrappedValue.dismiss()
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
        .alert(isPresented: self.$showSuccessMessage) {
            Alert(
                title: Text("Success"),
                message: Text("Profile updated successfully!"),
                dismissButton: .default(Text("OK")))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
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
        if self.newPassword != self.confirmPassword {
            self.errorMessage = "Passwords do not match"
            return
        }
        if self.newEmail.isEmpty && self.newUsername.isEmpty && self.newPassword.isEmpty {
            self.errorMessage = "Please fill in at least one field"
            return
        }

        self.errorMessage = ""

        // Update user information using AuthViewModel
        if !self.newUsername.isEmpty {
            let (_, error) = await authViewModel.updateUsername(newUsername: self.newUsername)
            if let error = error {
                self.errorMessage = error
                return
            }
        }

        if !self.newEmail.isEmpty {
            do {
                try await self.authViewModel.updateEmail(newEmail: self.newEmail)
            } catch {
                self.errorMessage = error.localizedDescription
                return
            }
        }

        if !self.newPassword.isEmpty {
            do {
                try await self.authViewModel.updatePassword(newPassword: self.newPassword)
            } catch {
                self.errorMessage = error.localizedDescription
                return
            }
        }

        // Show success message and reset fields
        self.showSuccessMessage = true
        self.resetFields()
    }

    private func resetFields() {
        self.newUsername = ""
        self.newEmail = ""
        self.newPassword = ""
        self.confirmPassword = ""
        self.errorMessage = ""
    }
}

#Preview {
    ProfileEditView()
        .environmentObject(AuthViewModel())
        .environmentObject(NotesViewModel())
}
