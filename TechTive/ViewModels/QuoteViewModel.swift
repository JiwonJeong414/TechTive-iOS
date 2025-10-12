import SwiftUI

class QuoteViewModel: ObservableObject {
    @Published var quote = "Loading..."

    // Dependencies
    weak var authViewModel: AuthViewModel?

    func fetchQuote() {
        // Fetch quote from API
        Task {
            await self.fetchQuoteFromAPI()
        }
    }

    /// Fetches quote from API
    func fetchQuoteFromAPI() async {
        do {
            print("🔍 Fetching quote from: \(Constants.API.baseURL + Constants.API.quotes)")
            let response = try await URLSession.getWithoutAuth(
                endpoint: Constants.API.quotes,
                responseType: Quote.self)

            print("✅ Quote response received: \(response)")
            await MainActor.run {
                self.quote = "\(response.content)\n— \(response.author)"
                print("📝 Quote set to: \(self.quote)")
            }
        } catch {
            print("❌ Error fetching quote: \(error)")
            await MainActor.run {
                self.quote = "" // Show empty state
            }
        }
    }
}
