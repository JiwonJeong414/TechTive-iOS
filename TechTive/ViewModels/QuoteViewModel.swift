import SwiftUI

class QuoteViewModel: ObservableObject {
    @Published var quote = "Loading..."
    
    private var fetchTask: Task<Void, Never>?
    
    deinit {
        fetchTask?.cancel()
    }
        
    func fetchQuote() {
        Task {
            await self.fetchQuoteFromAPI()
        }
    }

    func fetchQuoteFromAPI() async {
        // Cancel any existing fetch
        fetchTask?.cancel()
        
        // Create new fetch task
        fetchTask = Task {
            do {
                let response = try await NetworkManager.shared.getRandomQuote()
                
                // Check for cancellation before updating UI
                try Task.checkCancellation()
                
                await MainActor.run {
                    self.quote = "\(response.content)\n— \(response.author)"
                }
            } catch is CancellationError {
                // Silently handle cancellation - don't update quote
                print("Quote fetch cancelled successfully")
            } catch {
                print("Error fetching quote: \(error)")
                await MainActor.run {
                    // Keep previous quote or show empty on error
                    if self.quote == "Loading..." {
                        self.quote = ""
                    }
                }
            }
        }
        
        await fetchTask?.value
    }
}
