import SwiftUI

/// ViewModel responsible for managing notes in the app
class NotesViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Dependencies

    weak var authViewModel: AuthViewModel?

    // MARK: - Initialization

    init(authViewModel: AuthViewModel? = nil) {
        self.authViewModel = authViewModel
        self.loadNotes()
        Task {
            await self.fetchNotes()
        }
    }

    // MARK: - Public Methods

    /// Calculates the number of notes per week for the last 5 weeks
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

    /// Calculates the longest streak of consecutive weeks with notes
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

    /// Fetches notes from the API
    func fetchNotes() async {
        await MainActor.run { self.isLoading = true }

        do {
            guard let authViewModel = authViewModel else {
                throw NetworkError.authenticationFailed
            }

            let token = try await authViewModel.getAuthToken()
            let response = try await URLSession.get(
                endpoint: Constants.API.posts,
                token: token,
                responseType: PostsResponse.self)

            await MainActor.run {
                self.notes = response.posts.sorted { $0.timestamp > $1.timestamp }
                self.isLoading = false
                self.objectWillChange.send()
            }
        } catch {
            print("❌ Error fetching notes: \(error)")
            await MainActor.run {
                self.error = error
                self.isLoading = false
                // If we have no notes and API fails, use dummy data as fallback
                if self.notes.isEmpty {
                    print("📝 Using dummy data as fallback for notes")
                    self.notes = DummyData.shared.notes
                }
                self.objectWillChange.send()
            }
        }
    }

    /// Adds a new note to the collection
    func addNewNote(_ note: Note) {
        self.notes.insert(note, at: 0)
        self.saveNotes()
    }

    /// Updates an existing note
    func updateNote(_ updatedNote: Note) {
        if let index = notes.firstIndex(where: { $0.id == updatedNote.id }) {
            self.notes[index] = updatedNote
            self.saveNotes()
        }
    }

    /// Posts a new note to the API
    @MainActor func postNote(content: String, formatting: [Note.TextFormatting]) async throws {
        guard let authViewModel = authViewModel else {
            throw NetworkError.authenticationFailed
        }

        let token = try await authViewModel.getAuthToken()

        let parameters: [String: Any] = [
            "content": content,
            "formatting": formatting.map { format in
                [
                    "range": [
                        "location": format.range.location,
                        "length": format.range.length
                    ],
                    "type": format.type.rawValue
                ]
            }
        ]

        let response = try await URLSession.post(
            endpoint: Constants.API.posts,
            token: token,
            parameters: parameters,
            responseType: PostResponse.self)

        // Add the new post to local collection
        await MainActor.run {
            self.notes.insert(response.post, at: 0)
            self.saveNotes()
        }
    }

    // MARK: - Private Methods

    /// Saves notes to UserDefaults
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "savedNotes")
        }
    }

    /// Loads notes from UserDefaults
    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.data(forKey: "savedNotes"),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedNotes)
        {
            self.notes = decodedNotes
        }
    }
}
