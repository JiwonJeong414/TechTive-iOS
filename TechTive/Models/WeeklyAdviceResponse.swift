import Foundation

struct WeeklyAdviceResponse: Codable {
    let id: Int
    let content: String
    let createdAt: String
    let ofWeek: String
    let userId: Int
}
