//
//  NotesViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    
    
    func notesPerWeek() -> [(week: String, count: Int)] {
            let calendar = Calendar.current
            var weeklyCounts: [(week: String, count: Int)] = []

            for i in 0..<5 {
                let startOfWeek = calendar.date(byAdding: .weekOfYear, value: -i, to: Date())?.startOfWeek ?? Date()
                let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? Date()
                let count = notes.filter { $0.timestamp >= startOfWeek && $0.timestamp <= endOfWeek }.count
                let weekLabel = DateFormatter.localizedString(from: startOfWeek, dateStyle: .short, timeStyle: .none)
                weeklyCounts.append((week: weekLabel, count: count))
            }

            return weeklyCounts.reversed() // Ensure the order is from oldest to newest
        }
    
    // Update addNote to handle formatted text
    func addNote(attributedString: NSAttributedString, userId: String) {
        let newNote = Note(attributedString: attributedString, userId: userId)
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    func deleteNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
            saveNotes()
        }
    }

    func updateNote(_ updatedNote: Note) {
        if let index = notes.firstIndex(where: { $0.id == updatedNote.id }) {
            notes[index] = updatedNote
            saveNotes()
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
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedNotes) {
            notes = decodedNotes
        }
    }
    func currentStreak() -> Int {
        let calendar = Calendar.current
        let sortedNotes = notes.sorted(by: { $0.timestamp > $1.timestamp }) // Sort notes by most recent
        guard let mostRecentDate = sortedNotes.first?.timestamp else { return 0 }

        var streak = 0
        var currentDate = mostRecentDate

        for note in sortedNotes {
            if calendar.isDate(note.timestamp, inSameDayAs: currentDate) {
                // Note is on the current streak date
                continue
            } else if let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate),
                      calendar.isDate(note.timestamp, inSameDayAs: previousDay) {
                // Note is on the previous day in the streak
                streak += 1
                currentDate = previousDay
            } else {
                // Streak is broken
                break
            }
        }

        // Add 1 to streak because the most recent note starts the streak
        return streak + 1
    }

    
    init() {
        loadNotes()
    }
}
extension Date {
    var startOfWeek: Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
