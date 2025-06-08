struct ProfileEditView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var newUsername = ""
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showSuccessMessage = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Spacer().frame(height: 40)

            // Title
            Text("Edit Profile")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
                .padding(.bottom, 20)

            // Form
            VStack(spacing: 20) {
                // Username Field
                TextField("New Username", text: self.$newUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)

                // Email Field
                TextField("New Email", text: self.$newEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .keyboardType(.emailAddress)

                // Password Field
                SecureField("New Password", text: self.$newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)

                // Confirm Password Field
                SecureField("Confirm Password", text: self.$confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    self.handleSaveChanges()
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
                    self.resetFields()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "F3E5F5"))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()
        }
        .background(Color(hex: "FFF3E0").ignoresSafeArea())
        .alert(isPresented: self.$showSuccessMessage) {
            Alert(
                title: Text("Success"),
                message: Text("Profile updated successfully!"),
                dismissButton: .default(Text("OK")))
        }
    }

    private func handleSaveChanges() {
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
            self.authViewModel.updateUsername(newUsername: self.newUsername) { _, error in
                if let error = error {
                    self.errorMessage = error
                }
            }
        }
        if !self.newEmail.isEmpty {
            self.authViewModel.updateEmail(newEmail: self.newEmail)
        }
        if !self.newPassword.isEmpty {
            self.authViewModel.updatePassword(newPassword: self.newPassword)
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
