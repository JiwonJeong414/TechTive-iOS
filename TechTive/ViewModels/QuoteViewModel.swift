import SwiftUI

class QuoteViewModel: ObservableObject {
    @Published var quote = "Loading..."

    // Dependencies
    weak var authViewModel: AuthViewModel?

    func fetchQuote() {
        // For now, use dummy data as fallback since we don't have a quotes API endpoint
        // TODO: Implement real quotes API endpoint
        let quotes = DummyData.shared.quotes
        if let randomQuote = quotes.randomElement() {
            self.quote = "\(randomQuote.quote)\n— \(randomQuote.author)"
        } else {
            self.quote = "Failed to fetch quote. Please try again."
        }
    }

    /// Fetches quote from API (when endpoint is available)
    func fetchQuoteFromAPI() async {
        guard let authViewModel = authViewModel else {
            await MainActor.run {
                self.quote = "Authentication required"
            }
            return
        }

        do {
            let token = try await authViewModel.getAuthToken()
            // TODO: Replace with actual quotes endpoint when available
            // let response = try await URLSession.get(
            //     endpoint: Constants.API.quotes,
            //     token: token,
            //     responseType: QuoteResponse.self
            // )

            // For now, fall back to dummy data
            await MainActor.run {
                self.fetchQuote()
            }
        } catch {
            print("❌ Error fetching quote: \(error)")
            await MainActor.run {
                self.fetchQuote() // Fallback to dummy data
            }
        }
    }
}
