import SwiftUI

struct NotesResponse: Codable {
    let posts: [Note]
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var error: Error?

    weak var authViewModel: AuthViewModel?

    init(authViewModel: AuthViewModel? = nil) {
        self.authViewModel = authViewModel
        self.loadNotes()
        Task {
            await self.fetchNotes()
        }
    }

    func notesPerWeek() -> [(week: String, count: Int)] {
        let calendar = Calendar.current
        var weeklyCounts: [(week: String, count: Int)] = []

        for i in 0 ..< 5 {
            let startOfWeek = calendar.date(byAdding: .weekOfYear, value: -i, to: Date())?.startOfWeek ?? Date()
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date()
            let count = self.notes.filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek }.count
            let weekLabel = startOfWeek.localizedShortDate
            weeklyCounts.append((week: weekLabel, count: count))
        }

        return weeklyCounts.reversed()
    }

    func calculateLongestStreak() -> Int {
        let calendar = Calendar.current
        var currentStreak = 0
        var longestStreak = 0
        var currentDate = Date()

        // Get all dates when notes were created
        let noteDates = Set(notes.map { calendar.startOfDay(for: $0.timestamp) })

        // Check for consecutive weeks
        while currentDate > Date().addingTimeInterval(-365 * 24 * 60 * 60) { // Look back up to 1 year
            let startOfWeek = currentDate.startOfWeek ?? currentDate
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? currentDate

            // Check if there are any notes in this week
            let hasNotesThisWeek = noteDates.contains { date in
                date >= startOfWeek && date < endOfWeek
            }

            if hasNotesThisWeek {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }

            // Move to previous week
            currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) ?? currentDate
        }

        return longestStreak
    }

    func fetchNotes() async {
        await MainActor.run { self.isLoading = true }

        // Use dummy data instead of making API call
        await MainActor.run {
            self.notes = DummyData.shared.notes.sorted { $0.timestamp > $1.timestamp }
            self.isLoading = false
            self.objectWillChange.send()
        }
    }

    func addNewNote(_ note: Note) {
        self.notes.insert(note, at: 0)
        self.saveNotes()
    }

    func updateNote(_ updatedNote: Note) {
        if let index = notes.firstIndex(where: { $0.id == updatedNote.id }) {
            self.notes[index] = updatedNote
            self.saveNotes()
        }
    }

    // MARK: - Persistence

    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "savedNotes")
        }
    }

    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.data(forKey: "savedNotes"),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedNotes)
        {
            self.notes = decodedNotes
        }
    }

    @MainActor func postNote(content: String, formatting: [Note.TextFormatting]) async throws {
        // Create a new note with dummy data
        let newNote = Note(
            id: notes.count + 1,
            content: content,
            timestamp: Date(),
            userID: 1,
            formatting: formatting,
            angerValue: 0.1,
            disgustValue: 0.05,
            fearValue: 0.1,
            joyValue: 0.8,
            neutralValue: 0.3,
            sadnessValue: 0.1,
            surpriseValue: 0.2)

        await MainActor.run {
            self.notes.insert(newNote, at: 0)
            self.saveNotes()
        }
    }
}

extension Date {
    var startOfWeek: Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
