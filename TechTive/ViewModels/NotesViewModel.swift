//
//  NotesViewModel.swift
//  TechTive
//

import SwiftUI

/// ViewModel responsible for managing notes in the app
class NotesViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Initialization

    init() {
        self.loadNotes()
        // Fetch notes if user is authenticated
        if UserSessionManager.shared.accessToken != nil {
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
            // Simple network call using NetworkManager
            let response = try await NetworkManager.shared.getNotes()

            // Fetch individual notes with emotional analysis
            var notesWithEmotions: [Note] = []
            
            for (index, note) in response.notes.enumerated() {
                print("🔄 Fetching emotional analysis for note \(index + 1)/\(response.notes.count)")
                
                do {
                    let fullNote = try await NetworkManager.shared.getNote(id: note.id)
                    notesWithEmotions.append(fullNote)
                    print("Note \(index + 1) emotional data: \(fullNote.dominantEmotion.emotion)")
                } catch {
                    print("Failed to fetch emotional analysis for note \(note.id): \(error.localizedDescription)")
                    // Fallback to note without emotional analysis
                    notesWithEmotions.append(note)
                }
            }

            await MainActor.run {
                self.notes = notesWithEmotions.sorted { $0.timestamp > $1.timestamp }
                self.isLoading = false
                self.objectWillChange.send()
            }
        } catch {
            // Only print error if it's not a cancellation
            if !error.localizedDescription.contains("cancelled") {
                print("Failed to fetch notes: \(error.localizedDescription)")
            }
            await MainActor.run {
                self.error = error
                self.isLoading = false
                self.objectWillChange.send()
            }
        }
    }

    /// Creates a new note via API
    @MainActor func createNote(content: String, formattings: [Note.TextFormatting]) async throws {
        // Create type-safe request body
        let body = CreateNoteBody(
            content: content,
            formattings: formattings.map { format in
                CreateNoteBody.FormattingData(
                    type: format.type.rawValue,
                    location: format.location,
                    length: format.length
                )
            }
        )

        // Debug: Print what we're sending
        print("📤 Sending note to backend:")
        print("   Content: '\(content)'")
        print("   Formattings: \(formattings.map { "\($0.type.rawValue) at \($0.location) length \($0.length)" })")

        // Simple network call using NetworkManager
        let newNote = try await NetworkManager.shared.createNote(body: body)

        // Debug: Check if the created note has emotional analysis data
        print("📝 Created note emotional data:")
        print("   Content: '\(newNote.content)'")
        print("   Dominant: \(newNote.dominantEmotion.emotion)")

        // Add the new note to local collection
        await MainActor.run {
            self.notes.insert(newNote, at: 0)
            self.saveNotes()
            self.objectWillChange.send() // Force UI update
        }

        // Refresh notes to get emotional analysis data
        await self.fetchNotes()
    }

    /// Deletes a note via API
    @MainActor func deleteNote(id: Int) async throws {
        // Simple network call using NetworkManager
        try await NetworkManager.shared.deleteNote(id: id)

        // Remove the note from local collection
        await MainActor.run {
            self.notes.removeAll { $0.id == id }
            self.saveNotes()
            self.objectWillChange.send() // Force UI update
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
