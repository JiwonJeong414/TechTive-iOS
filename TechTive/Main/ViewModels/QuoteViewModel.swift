//
//  QuoteViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/30/24.
//

import SwiftUI
import Alamofire

class QuoteViewModel: ObservableObject {
    @Published var quote = "Loading..."
    
    func fetchQuote() {
        let url = "https://qapi.vercel.app/api/random"
        
        AF.request(url).responseDecodable(of: Quote.self) { response in
            switch response.result {
            case .success(let decodedQuote):
                DispatchQueue.main.async {
                    self.quote = "\(decodedQuote.quote)\n— \(decodedQuote.author)"
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.quote = "Failed to fetch quote. Please try again."
                }
                print("Error fetching quote: \(error.localizedDescription)")
            }
        }
    }
}

struct Quote: Codable {
    let id: Int
    let quote: String
    let author: String
}
