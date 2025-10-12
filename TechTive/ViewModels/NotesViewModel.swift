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
            let fetchedNotes = try await fetchAllNotes(token: token)

            await MainActor.run {
                self.notes = fetchedNotes.sorted { $0.timestamp > $1.timestamp }
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

    /// Creates a new note via API
    @MainActor func createNote(content: String, formattings: [Note.TextFormatting]) async throws {
        guard let authViewModel = authViewModel else {
            throw NetworkError.authenticationFailed
        }

        let token = try await authViewModel.getAuthToken()
        let newNote = try await createNoteAPI(content: content, formattings: formattings, token: token)

        // Add the new note to local collection
        await MainActor.run {
            self.notes.insert(newNote, at: 0)
            self.saveNotes()
        }
    }

    /// Updates an existing note via API
    @MainActor func updateNoteAPI(id: Int, content: String, formattings: [Note.TextFormatting]) async throws {
        guard let authViewModel = authViewModel else {
            throw NetworkError.authenticationFailed
        }

        let token = try await authViewModel.getAuthToken()
        let updatedNote = try await updateNoteAPI(id: id, content: content, formattings: formattings, token: token)

        // Update the note in local collection
        await MainActor.run {
            if let index = self.notes.firstIndex(where: { $0.id == id }) {
                self.notes[index] = updatedNote
                self.saveNotes()
            }
        }
    }

    /// Deletes a note via API
    @MainActor func deleteNoteAPI(id: Int) async throws {
        guard let authViewModel = authViewModel else {
            throw NetworkError.authenticationFailed
        }

        let token = try await authViewModel.getAuthToken()
        try await self.deleteNoteAPI(id: id, token: token)

        // Remove the note from local collection
        await MainActor.run {
            self.notes.removeAll { $0.id == id }
            self.saveNotes()
        }
    }

    // MARK: - API Methods

    /// Fetches all notes from the API
    private func fetchAllNotes(token: String) async throws -> [Note] {
        let response = try await URLSession.get(
            endpoint: Constants.API.notes,
            token: token,
            responseType: NotesResponse.self)
        return response.notes
    }

    /// Fetches a specific note by ID
    private func fetchNote(id: Int, token: String) async throws -> Note {
        let response = try await URLSession.get(
            endpoint: "\(Constants.API.note)\(id)/",
            token: token,
            responseType: NoteResponse.self)
        return response.note
    }

    /// Creates a new note via API
    private func createNoteAPI(
        content: String,
        formattings: [Note.TextFormatting],
        token: String) async throws -> Note
    {
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

        let response = try await URLSession.post(
            endpoint: Constants.API.notes,
            token: token,
            parameters: parameters,
            responseType: NoteResponse.self)
        return response.note
    }

    /// Updates an existing note via API
    private func updateNoteAPI(
        id: Int,
        content: String,
        formattings: [Note.TextFormatting],
        token: String) async throws -> Note
    {
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

        let response = try await URLSession.put(
            endpoint: "\(Constants.API.note)\(id)/",
            token: token,
            parameters: parameters,
            responseType: NoteResponse.self)
        return response.note
    }

    /// Deletes a note by ID via API
    private func deleteNoteAPI(id: Int, token: String) async throws {
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await URLSession.delete(
            endpoint: "\(Constants.API.note)\(id)/",
            token: token,
            responseType: EmptyResponse.self)
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
