import SwiftUI

extension WeeklyOverviewSection {
    @MainActor final class ViewModel: ObservableObject {
        @Published var weeklyAdvice: WeeklyAdviceResponse?
        @Published var errorMessage: String?
        
        func fetchWeeklyAdvice() async {
            do {
                let response = try await NetworkManager.shared.getLatestAdvice()
                
                await MainActor.run {
                    self.weeklyAdvice = response
                    self.errorMessage = nil
                }
            } catch {
                print("Error fetching weekly advice: \(error)")
                await MainActor.run {
                    if (error as? ErrorResponse)?.httpCode == 404 {
                        self.errorMessage = "Not enough notes for weekly advice"
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    self.weeklyAdvice = nil
                }
            }
        }
    }
}
