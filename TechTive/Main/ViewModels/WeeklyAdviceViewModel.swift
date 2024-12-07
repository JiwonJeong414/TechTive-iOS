//
//  WeeklyAdviceViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 12/6/24.
//
import SwiftUI
import Alamofire

class WeeklyAdviceViewModel: ObservableObject {
    @Published var weeklyAdvice: String = "Loading..."
    
    func fetchWeeklyAdvice() {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjNmZDA3MG"
        ]
        
        AF.request("https://631c-128-84-124-32.ngrok-free.app/api/weekly_advice",
                   method: .get,
                   headers: headers)
        .responseDecodable(of: WeeklyAdviceResponse.self) { response in
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.weeklyAdvice = data.weekly_advice.content
                }
            case .failure(let error):
                print("Error fetching weekly advice: \(error)")
                self.weeklyAdvice = "Failed to load weekly advice"
            }
        }
    }
}

struct WeeklyAdviceResponse: Codable {
    let message: String
    let weekly_advice: WeeklyAdvice
    
    struct WeeklyAdvice: Codable {
        let content: String
        let created_at: String
        let id: Int
        let of_week: String
        let user_id: Int
    }
}
