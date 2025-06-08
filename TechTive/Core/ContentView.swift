import SwiftUI

#if DEBUG
    import Inject
#endif

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
                        .font(.custom("Poppins-Regular", fixedSize: 16))
                        .foregroundColor(.gray)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
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
