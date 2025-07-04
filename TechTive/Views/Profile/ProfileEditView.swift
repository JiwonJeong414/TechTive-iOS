import SwiftUI

/// View in profile Section where you update User's profile information
struct ProfileEditView: View {
    // MARK: - Properties

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ProfileView.ViewModel

    private let darkPurple = Color(Constants.Colors.darkPurple)

    // MARK: - UI

    var body: some View {
        VStack {
            Spacer().frame(height: 40)

            self.headerSection
            self.formSection
            self.buttonSection

            Spacer()
        }
        .background(Color(Constants.Colors.backgroundColor))
        .ignoresSafeArea()
        .alert(isPresented: self.$viewModel.showSuccessMessage) {
            Alert(
                title: Text("Success"),
                message: Text("Profile updated successfully!"),
                dismissButton: .default(Text("OK")))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                self.backButton
            }
        }
    }

    private var headerSection: some View {
        Text("Edit Profile")
            .font(.custom("Poppins-SemiBold", fixedSize: 32))
            .foregroundColor(self.darkPurple)
            .padding(.bottom, 20)
    }

    private var formSection: some View {
        VStack(spacing: 20) {
            self.usernameField
            self.emailField
            self.passwordField
            self.confirmPasswordField

            if !self.viewModel.errorMessage.isEmpty {
                Text(self.viewModel.errorMessage)
                    .foregroundColor(Color(Constants.Colors.red))
                    .font(.caption)
                    .padding(.top, 10)
            }
        }
    }

    private var usernameField: some View {
        TextField("Change Username", text: self.$viewModel.newUsername)
            .textFieldStyle(CustomTextFieldStyle())
            .autocapitalization(.none)
            .font(Constants.Fonts.poppinsRegular16)
            .padding(.horizontal, 20)
    }

    private var emailField: some View {
        TextField("Change Email", text: self.$viewModel.newEmail)
            .textFieldStyle(CustomTextFieldStyle())
            .autocapitalization(.none)
            .font(Constants.Fonts.poppinsRegular16)
            .keyboardType(.emailAddress)
            .padding(.horizontal, 20)
    }

    private var passwordField: some View {
        SecureField("Change Password", text: self.$viewModel.newPassword)
            .textFieldStyle(CustomTextFieldStyle())
            .autocapitalization(.none)
            .font(Constants.Fonts.poppinsRegular16)
            .padding(.horizontal, 20)
    }

    private var confirmPasswordField: some View {
        SecureField("Confirm New Password", text: self.$viewModel.confirmPassword)
            .textFieldStyle(CustomTextFieldStyle())
            .autocapitalization(.none)
            .font(Constants.Fonts.poppinsRegular16)
            .padding(.horizontal, 20)
    }

    private var buttonSection: some View {
        HStack(spacing: 20) {
            self.saveButton
            self.cancelButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var saveButton: some View {
        Button(action: {
            Task {
                await self.viewModel.handleSaveChanges()
            }
        }) {
            Text("Save Changes")
                .frame(maxWidth: .infinity)
                .padding()
                .font(.custom("CourierPrime-Regular", fixedSize: 16))
                .background(Color(Constants.Colors.deepOrange))
                .foregroundColor(Color(Constants.Colors.white))
                .cornerRadius(10)
        }
    }

    private var cancelButton: some View {
        Button(action: {
            self.viewModel.resetFields()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel")
                .frame(maxWidth: .infinity)
                .padding()
                .font(.custom("CourierPrime-Regular", fixedSize: 16))
                .background(Color(Constants.Colors.lightPurple))
                .foregroundColor(Color(Constants.Colors.black))
                .cornerRadius(10)
        }
    }

    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(Constants.Colors.orange))
                Text("Back")
                    .font(.custom("Poppins-Medium", fixedSize: 16))
                    .foregroundColor(Color(Constants.Colors.orange))
            }
        }
    }
}
