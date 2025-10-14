import SwiftUI

class QuoteViewModel: ObservableObject {
    @Published var quote = "Loading..."
        
    func fetchQuote() {
        Task {
            await self.fetchQuoteFromAPI()
        }
    }

    func fetchQuoteFromAPI() async {
        do {
            let response = try await NetworkManager.shared.getRandomQuote()
            
            await MainActor.run {
                self.quote = "\(response.content)\n— \(response.author)"
            }
        } catch {
            print("Error fetching quote: \(error)")
            await MainActor.run {
                self.quote = "" // Show empty state
            }
        }
    }
}
