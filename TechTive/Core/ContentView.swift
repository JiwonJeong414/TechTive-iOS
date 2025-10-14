import SwiftUI

// MARK: - Main App Structure

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if self.authViewModel.isInitializing || self.authViewModel.isLoadingUserInfo {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(Constants.Fonts.poppinsRegular16)
                        .foregroundColor(Color(Constants.Colors.gray))
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(Constants.Colors.backgroundColor))
            } else if self.authViewModel.isAuthenticated {
                MainView()
            } else if self.authViewModel.isSecondState {
                LoginView()
            } else {
                AuthenticationFlow()
            }
        }
    }
}
