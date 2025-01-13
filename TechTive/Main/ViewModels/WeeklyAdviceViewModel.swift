//
//  WeeklyAdviceViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 12/6/24.
//

import SwiftUI
import Alamofire

@MainActor
final class WeeklyAdviceViewModel: ObservableObject {
    @Published var weeklyAdvice: WeeklyAdviceResponse?
    @Published var errorMessage: String?
    
    private let authViewModel = AuthViewModel()
    private let baseURL = "http://34.21.62.193/api/advices/latest/"
    
    func fetchWeeklyAdvice() async {
        do {
            let token = try await authViewModel.getAuthToken()
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Accept": "application/json"
            ]
            
            let response = try await AF.request(baseURL, headers: headers)
                .validate()
                .serializingDecodable(WeeklyAdviceResponse.self)
                .value
            
            self.weeklyAdvice = response
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error: \(error)")
        }
    }
}

// Models matching exact JSON structure
struct WeeklyAdviceResponse: Codable {
    let advice: AdviceData
    let message: String
}

struct AdviceData: Codable {
    let content: AdviceContent?
    let createdAt: String?
    let id: Int
    let ofWeek: String?
    let userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case content
        case createdAt = "created_at"
        case id
        case ofWeek = "of_week"
        case userId = "user_id"
    }
    
    // Computed property to check if advice is valid
    var isAdviceAvailable: Bool {
        if let content = content {
            return !content.advice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }
}

struct AdviceContent: Codable {
    let advice: String
    let answer: String
    let riddle: String
}
