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
        // Only fetch notes if we have an authViewModel
        if authViewModel != nil {
            Task {
                await self.fetchNotes()
            }
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
            let fetchedNotes = try await fetchAllNotes(token: token)

            await MainActor.run {
                self.notes = fetchedNotes.sorted { $0.timestamp > $1.timestamp }
                self.isLoading = false
                self.objectWillChange.send()
            }
        } catch {
            print("❌ Failed to fetch notes: \(error.localizedDescription)")
            await MainActor.run {
                self.error = error
                self.isLoading = false
                self.objectWillChange.send()
            }
        }
    }

    /// Creates a new note via API
    @MainActor func createNote(content: String, formattings: [Note.TextFormatting]) async throws {
        guard let authViewModel = authViewModel else {
            throw NetworkError.authenticationFailed
        }

        let token = try await authViewModel.getAuthToken()

        // Prepare parameters for API call
        let parameters: [String: Any] = [
            "content": content,
            "formattings": formattings.map { format in
                [
                    "type": format.type.rawValue,
                    "location": format.location,
                    "length": format.length
                ]
            }
        ]

        // Debug: Print what we're sending to the backend
        print("📤 Sending note to backend:")
        print("   Content: '\(content)'")
        print("   Formattings: \(formattings.map { "\($0.type.rawValue) at \($0.location) length \($0.length)" })")
        if let jsonData = try? JSONSerialization.data(withJSONObject: parameters),
           let jsonString = String(data: jsonData, encoding: .utf8)
        {
            print("   JSON: \(jsonString)")
        }

        // Create note via API
        let newNote = try await URLSession.post(
            endpoint: Constants.API.notes,
            token: token,
            parameters: parameters,
            responseType: Note.self)

        // Debug: Check if the created note has emotional analysis data
        print("📝 Created note emotional data:")
        print("   Content: '\(newNote.content)'")
        print("   Joy: \(newNote.joyValue), Neutral: \(newNote.neutralValue)")
        print("   Dominant: \(newNote.dominantEmotion.emotion)")
        print(
            "   All emotions: anger=\(newNote.angerValue), disgust=\(newNote.disgustValue), fear=\(newNote.fearValue), joy=\(newNote.joyValue), neutral=\(newNote.neutralValue), sadness=\(newNote.sadnessValue), surprise=\(newNote.surpriseValue)")

        // Add the new note to local collection
        await MainActor.run {
            self.notes.insert(newNote, at: 0)
            self.saveNotes()
            self.objectWillChange.send() // Force UI update
        }

        // Refresh notes to get emotional analysis data
        // The backend might process emotional analysis asynchronously
        await self.fetchNotes()
    }

    /// Deletes a note via API
    @MainActor func deleteNote(id: Int) async throws {
        guard let authViewModel = authViewModel else {
            throw NetworkError.authenticationFailed
        }

        let token = try await authViewModel.getAuthToken()

        // Delete note via API
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await URLSession.delete(
            endpoint: "\(Constants.API.notes)\(id)/",
            token: token,
            responseType: EmptyResponse.self)

        // Remove the note from local collection
        await MainActor.run {
            self.notes.removeAll { $0.id == id }
            self.saveNotes()
            self.objectWillChange.send() // Force UI update
        }
    }

    // MARK: - API Methods

    /// Fetches all notes from the API
    private func fetchAllNotes(token: String) async throws -> [Note] {
        let response = try await URLSession.get(
            endpoint: Constants.API.notes,
            token: token,
            responseType: NotesResponse.self)

        print("✅ Notes fetched: \(response.notes.count) notes")

        // Notes list API doesn't include emotional analysis data
        // We need to fetch each note individually to get emotional analysis
        var notesWithEmotions: [Note] = []

        for (index, note) in response.notes.enumerated() {
            print(
                "🔄 Fetching emotional analysis for note \(index + 1)/\(response.notes.count): '\(note.content.prefix(20))...'")

            do {
                // Fetch individual note with emotional analysis
                let fullNote = try await fetchIndividualNote(id: note.id, token: token)
                notesWithEmotions.append(fullNote)

                print(
                    "✅ Note \(index + 1) emotional data: \(fullNote.dominantEmotion.emotion) (\(fullNote.dominantEmotion.value))")
            } catch {
                print("❌ Failed to fetch emotional analysis for note \(note.id): \(error.localizedDescription)")
                // Fallback to note without emotional analysis
                notesWithEmotions.append(note)
            }
        }

        return notesWithEmotions
    }

    /// Fetches a specific note by ID with emotional analysis
    private func fetchIndividualNote(id: Int, token: String) async throws -> Note {
        let note = try await URLSession.get(
            endpoint: "\(Constants.API.notes)\(id)/",
            token: token,
            responseType: Note.self)
        return note
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
