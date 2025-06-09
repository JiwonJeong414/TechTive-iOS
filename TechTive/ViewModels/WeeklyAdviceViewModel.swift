import SwiftUI

@MainActor final class WeeklyAdviceViewModel: ObservableObject {
    @Published var weeklyAdvice: WeeklyAdviceResponse?
    @Published var errorMessage: String?

    func fetchWeeklyAdvice() async {
        // Use dummy data instead of making API call
        self.weeklyAdvice = DummyData.shared.weeklyAdvice
        self.errorMessage = nil
    }
}
