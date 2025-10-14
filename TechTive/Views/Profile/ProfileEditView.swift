//
//  ProfileEditView.swift
//  TechTive
//
//  Rebuilt from scratch with proper state management
//

import SwiftUI

struct ProfileEditView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case username, email, password, confirmPassword
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                formSection
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
        .background(Color(Constants.Colors.backgroundColor))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .alert("Success", isPresented: $viewModel.showSuccessMessage) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Profile updated successfully!")
        }
        .onAppear {
            viewModel.resetForm()
        }
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        Text("Edit Profile")
            .font(Constants.Fonts.poppinsSemiBold32)
            .foregroundColor(Color(Constants.Colors.darkPurple))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            usernameField
            emailField
            passwordField
            confirmPasswordField
            
            if !viewModel.errorMessage.isEmpty {
                errorMessageView
            }
        }
    }
    
    private var usernameField: some View {
        TextField("Change Username", text: $viewModel.newUsername)
            .textFieldStyle(CustomTextFieldStyle())
            .autocapitalization(.none)
            .font(Constants.Fonts.poppinsRegular16)
            .focused($focusedField, equals: .username)
            .disabled(viewModel.isProcessing)
    }
    
    private var emailField: some View {
        TextField("Change Email", text: $viewModel.newEmail)
            .textFieldStyle(CustomTextFieldStyle())
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .font(Constants.Fonts.poppinsRegular16)
            .focused($focusedField, equals: .email)
            .disabled(viewModel.isProcessing)
    }
    
    private var passwordField: some View {
        SecureField("Change Password", text: $viewModel.newPassword)
            .textFieldStyle(CustomTextFieldStyle())
            .autocapitalization(.none)
            .font(Constants.Fonts.poppinsRegular16)
            .focused($focusedField, equals: .password)
            .disabled(viewModel.isProcessing)
    }
    
    private var confirmPasswordField: some View {
        SecureField("Confirm New Password", text: $viewModel.confirmPassword)
            .textFieldStyle(CustomTextFieldStyle())
            .autocapitalization(.none)
            .font(Constants.Fonts.poppinsRegular16)
            .focused($focusedField, equals: .confirmPassword)
            .disabled(viewModel.isProcessing)
    }
    
    private var errorMessageView: some View {
        Text(viewModel.errorMessage)
            .foregroundColor(Color(Constants.Colors.red))
            .font(Constants.Fonts.poppinsRegular14)
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            saveButton
            cancelButton
        }
    }
    
    private var saveButton: some View {
        Button(action: handleSave) {
            Group {
                if viewModel.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Save Changes")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .font(Constants.Fonts.courierPrime16)
            .background(Color(Constants.Colors.deepOrange))
            .foregroundColor(Color(Constants.Colors.white))
            .cornerRadius(10)
        }
        .disabled(viewModel.isProcessing)
    }
    
    private var cancelButton: some View {
        Button(action: handleCancel) {
            Text("Cancel")
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .font(Constants.Fonts.courierPrime16)
                .background(Color(Constants.Colors.lightPurple))
                .foregroundColor(Color(Constants.Colors.black))
                .cornerRadius(10)
        }
        .disabled(viewModel.isProcessing)
    }
    
    private var backButton: some View {
        Button(action: handleCancel) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Back")
                    .font(Constants.Fonts.poppinsMedium16)
            }
            .foregroundColor(Color(Constants.Colors.orange))
        }
        .disabled(viewModel.isProcessing)
    }
    
    // MARK: - Actions
    
    private func handleSave() {
        focusedField = nil
        
        Task {
            let success = await viewModel.saveProfileChanges()
            if success {
                // Success alert will show and dismiss
            }
        }
    }
    
    private func handleCancel() {
        viewModel.resetForm()
        dismiss()
    }
}
