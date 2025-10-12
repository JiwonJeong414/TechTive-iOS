import Foundation

struct WeeklyAdviceResponse: Codable {
    let message: String
    let user_id: String?
    let content: WeeklyAdviceContent?
    let created_at: String?
    let week_of: String?

    // Provide default values for missing content
    var safeContent: WeeklyAdviceContent {
        return self.content ?? WeeklyAdviceContent(
            riddle: "What has keys but no locks, space but no room, and you can enter but not go inside?",
            answer: "A keyboard",
            advice: "Based on your recent entries, you've been showing great progress in managing your emotions. Keep up the positive mindset!")
    }
}

struct WeeklyAdviceContent: Codable {
    let riddle: String
    let answer: String
    let advice: String
}
