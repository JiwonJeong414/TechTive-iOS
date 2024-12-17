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
    private let authViewModel = AuthViewModel()

    func fetchWeeklyAdvice() async {
        do {
            let url = URL(string: "https://631c-128-84-124-32.ngrok-free.app/api/weekly_advice")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(try await authViewModel.getAuthToken())", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)
            let weeklyAdviceResponse = try JSONDecoder().decode(WeeklyAdviceResponse.self, from: data)

            DispatchQueue.main.async {
                self.weeklyAdvice = weeklyAdviceResponse.message
            }
        } catch {
            print("Error fetching weekly advice: \(error)")
            DispatchQueue.main.async {
                self.weeklyAdvice = "Failed to load weekly advice"
            }
        }
    }
}
struct WeeklyAdviceResponse: Codable {
    let message: String
}

struct WeeklyAdvice: Codable {
    let id: Int
    let content: String
    let ofWeek: String
    let createdAt: String
    let userId: Int
}
