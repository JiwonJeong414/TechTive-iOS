import Foundation

struct DummyData {
    static let shared = DummyData()

    // MARK: - Notes Data

    let notes: [Note] = [
        Note(
            id: 1,
            content: "Today was a productive day. I finished my project and learned a lot about SwiftUI.",
            timestamp: Date(),
            userID: 1,
            formatting: [],
            angerValue: 0.1,
            disgustValue: 0.05,
            fearValue: 0.1,
            joyValue: 0.8,
            neutralValue: 0.3,
            sadnessValue: 0.1,
            surpriseValue: 0.2),
        Note(
            id: 2,
            content: "Feeling a bit anxious about the upcoming presentation, but I know I can do it!",
            timestamp: Date().addingTimeInterval(-86400), // Yesterday
            userID: 1,
            formatting: [],
            angerValue: 0.2,
            disgustValue: 0.1,
            fearValue: 0.6,
            joyValue: 0.4,
            neutralValue: 0.3,
            sadnessValue: 0.2,
            surpriseValue: 0.1),
        Note(
            id: 3,
            content: "Had a great workout session today. Feeling energized and motivated!",
            timestamp: Date().addingTimeInterval(-172_800), // 2 days ago
            userID: 1,
            formatting: [],
            angerValue: 0.1,
            disgustValue: 0.05,
            fearValue: 0.1,
            joyValue: 0.9,
            neutralValue: 0.2,
            sadnessValue: 0.05,
            surpriseValue: 0.1)
    ]

    // MARK: - Weekly Advice Data

    let weeklyAdvice = WeeklyAdviceResponse(
        message: "Weekly advice generated successfully",
        user_id: "1",
        content: WeeklyAdviceContent(
            riddle: "What has keys but no locks, space but no room, and you can enter but not go inside?",
            answer: "A keyboard",
            advice: "Based on your recent entries, you've been showing great progress in managing your emotions. Keep up the positive mindset!"),
        created_at: "2024-03-25T12:00:00Z",
        week_of: "Week 12")

    // MARK: - Quote Data

    let quotes = [
        Quote(id: 1, quote: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        Quote(id: 2, quote: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs"),
        Quote(id: 3, quote: "Stay hungry, stay foolish.", author: "Steve Jobs")
    ]

    // MARK: - Profile Data

    let profileData = UserProfile(id: "user123", name: "Jiwon Jeong")
}
