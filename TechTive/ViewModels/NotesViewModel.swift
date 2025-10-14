//
//  NotesViewModel.swift
//  TechTive
//
//  Manages all note-related operations and state
//

import SwiftUI

class NotesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedNote: Note?
    @Published var showingEditor = false
    
    // MARK: - Initialization
    
    init() {
        loadNotes()
        if UserSessionManager.shared.accessToken != nil {
            Task {
                await fetchNotes()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Fetches notes from the API
    func fetchNotes() async {
        await MainActor.run { isLoading = true }
        
        do {
            let response = try await NetworkManager.shared.getNotes()
            
            var notesWithEmotions: [Note] = []
            
            for (index, note) in response.notes.enumerated() {
                print("🔄 Fetching emotional analysis for note \(index + 1)/\(response.notes.count)")
                
                do {
                    let fullNote = try await NetworkManager.shared.getNote(id: note.id)
                    notesWithEmotions.append(fullNote)
                } catch {
                    print("Failed to fetch emotional analysis for note \(note.id): \(error.localizedDescription)")
                    notesWithEmotions.append(note)
                }
            }
            
            await MainActor.run {
                notes = notesWithEmotions.sorted { $0.timestamp > $1.timestamp }
                isLoading = false
                objectWillChange.send()
            }
        } catch {
            if !error.localizedDescription.contains("cancelled") {
                print("Failed to fetch notes: \(error.localizedDescription)")
            }
            await MainActor.run {
                self.error = error
                isLoading = false
                objectWillChange.send()
            }
        }
    }
    
    /// Creates a new note via API
    @MainActor func createNote(content: String, formattings: [Note.TextFormatting]) async throws {
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
        
        let newNote = try await NetworkManager.shared.createNote(body: body)
        
        await MainActor.run {
            notes.insert(newNote, at: 0)
            saveNotes()
            objectWillChange.send()
        }
        
        await fetchNotes()
    }
    
    /// Deletes a note via API
    @MainActor func deleteNote(id: Int) async throws {
        try await NetworkManager.shared.deleteNote(id: id)
        
        await MainActor.run {
            notes.removeAll { $0.id == id }
            saveNotes()
            objectWillChange.send()
        }
    }
    
    /// Selects a note for editing
    func selectNote(_ note: Note) {
        selectedNote = note
        showingEditor = true
    }
    
    /// Calculates notes per week for the last 5 weeks
    func notesPerWeek() -> [(week: String, count: Int)] {
        let calendar = Calendar.current
        var weeklyCounts: [(week: String, count: Int)] = []
        
        for i in 0..<5 {
            let startOfWeek = calendar.date(byAdding: .weekOfYear, value: -i, to: Date())?.startOfWeek ?? Date()
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date()
            let count = notes.filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek }.count
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
        
        let noteDates = Set(notes.map { calendar.startOfDay(for: $0.timestamp) })
        
        while currentDate > Date().addingTimeInterval(-365 * 24 * 60 * 60) {
            let startOfWeek = currentDate.startOfWeek ?? currentDate
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? currentDate
            
            let hasNotesThisWeek = noteDates.contains { date in
                date >= startOfWeek && date < endOfWeek
            }
            
            if hasNotesThisWeek {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
            
            currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) ?? currentDate
        }
        
        return longestStreak
    }
    
    // MARK: - Private Methods
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "savedNotes")
        }
    }
    
    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.data(forKey: "savedNotes"),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedNotes) {
            notes = decodedNotes
        }
    }
}
