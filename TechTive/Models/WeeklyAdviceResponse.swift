import Foundation

struct WeeklyAdviceResponse: Codable {
    let content: String
    let created_at: String
    let id: Int
    let notes_analyzed_count: Int
    let trigger_type: String
    let user_id: Int
}
