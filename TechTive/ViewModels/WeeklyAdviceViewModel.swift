import SwiftUI

extension WeeklyOverviewSection {
    @MainActor final class ViewModel: ObservableObject {
        @Published var weeklyAdvice: WeeklyAdviceResponse?
        @Published var errorMessage: String?

        // Dependencies
        private var authViewModel: AuthViewModel?

        func setAuthViewModel(_ authViewModel: AuthViewModel) {
            self.authViewModel = authViewModel
        }

        func fetchWeeklyAdvice() async {
            do {
                guard let authViewModel = authViewModel else {
                    throw NetworkError.authenticationFailed
                }

                let token = try await authViewModel.getAuthToken()
                let response = try await URLSession.getWith404Handling(
                    endpoint: Constants.API.advice,
                    token: token,
                    responseType: WeeklyAdviceResponse.self)

                await MainActor.run {
                    self.weeklyAdvice = response
                    self.errorMessage = nil
                }
            } catch {
                print("❌ Error fetching weekly advice: \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.weeklyAdvice = nil
                }
            }
        }
    }
}
