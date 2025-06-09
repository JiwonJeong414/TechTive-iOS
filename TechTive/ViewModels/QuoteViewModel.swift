import SwiftUI

class QuoteViewModel: ObservableObject {
    @Published var quote = "Loading..."

    func fetchQuote() {
        // Use dummy data instead of making API call
        let quotes = DummyData.shared.quotes
        if let randomQuote = quotes.randomElement() {
            self.quote = "\(randomQuote.quote)\n— \(randomQuote.author)"
        } else {
            self.quote = "Failed to fetch quote. Please try again."
        }
    }
}
