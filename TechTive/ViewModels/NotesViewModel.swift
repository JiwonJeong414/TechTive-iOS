//
//  NotesViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import Alamofire
import SwiftUI

struct NotesResponse: Codable {
    let posts: [Note]
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = [] // Make sure Note conforms to Identifiable
    @Published var isLoading = false
    @Published var error: Error?

    weak var authViewModel: AuthViewModel? // Make it weak to avoid retain cycle

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
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date() // Changed from 6 to 7
            let count = self.notes.filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek }
                .count // Changed <= to
            let weekLabel = DateFormatter.localizedString(from: startOfWeek, dateStyle: .short, timeStyle: .none)
            weeklyCounts.append((week: weekLabel, count: count))
        }

        return weeklyCounts.reversed()
    }

    func fetchNotes() async {
        await MainActor.run { self.isLoading = true }

        do {
            guard let authViewModel = authViewModel else {
                print("Debug - Auth ViewModel is nil")
                throw URLError(.userAuthenticationRequired)
            }

            let url = "http://34.21.62.193/api/posts/"
            let token = try await authViewModel.getAuthToken()
//            print("Debug - Token received:", token)

            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)"
            ]
//            print("Debug - Request headers:", headers)

            let response = try await AF.request(
                url,
                method: .get,
                headers: headers)
                .validate() // Add validation
                .serializingDecodable(NotesResponse.self)
                .value

            await MainActor.run {
                self.notes = response.posts.sorted { $0.timestamp > $1.timestamp }
                self.isLoading = false
                self.objectWillChange.send()
            }
        } catch let error as AFError {
            print("Debug - Alamofire error:", error.localizedDescription)
            print("Debug - Response:", error.responseCode ?? "No response code")
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        } catch {
            print("Debug - Other error:", error.localizedDescription)
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }

    // Call this after successfully posting a new note
    func addNewNote(_ note: Note) {
        self.notes.insert(note, at: 0) // Insert at the beginning since it's newest
        self.saveNotes()

        // Refresh notes in the background
        Task {
            await self.fetchNotes()
        }
    }

//    func deleteNote(_ note: Note) {
//        if let index = notes.firstIndex(where: { $0.id == note.id }) {
//            notes.remove(at: index)
//            saveNotes()
//
//            // Sync with server after local deletion
//            Task {
//                await fetchNotes()
//            }
//        }
//    }

    func updateNote(_ updatedNote: Note) {
        if let index = notes.firstIndex(where: { $0.id == updatedNote.id }) {
            self.notes[index] = updatedNote
            self.saveNotes()

            // Sync with server after local update
            Task {
                await self.fetchNotes()
            }
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

    func calculateLongestStreak() -> Int {
        guard !self.notes.isEmpty else { return 0 }

        // Sort notes by date
        let sortedNotes = self.notes.sorted { $0.timestamp < $1.timestamp }

        // Group notes by week
        let calendar = Calendar.current
        var weeklyNotes: [Date: [Note]] = [:]

        for note in sortedNotes {
            // Get start of the week for the note's timestamp
            let weekStart = calendar.date(from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: note.timestamp))!
            if weeklyNotes[weekStart] == nil {
                weeklyNotes[weekStart] = []
            }
            weeklyNotes[weekStart]?.append(note)
        }

        // Sort weeks chronologically
        let sortedWeeks = weeklyNotes.keys.sorted()

        // Calculate streaks
        var currentStreak = 1
        var longestStreak = 1

        for i in 1 ..< sortedWeeks.count {
            let currentWeek = sortedWeeks[i]
            let previousWeek = sortedWeeks[i - 1]

            // Check if weeks are consecutive
            let weekDifference = calendar.dateComponents(
                [.weekOfYear],
                from: previousWeek,
                to: currentWeek).weekOfYear ?? 0

            if weekDifference == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return longestStreak
    }

    // Get current streak
    func getCurrentStreak() -> Int {
        guard !self.notes.isEmpty else { return 0 }

        let calendar = Calendar.current
        let currentWeekStart = calendar.date(from: calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: Date()))!

        // Group notes by week
        var weeklyNotes: [Date: [Note]] = [:]
        for note in self.notes {
            let weekStart = calendar.date(from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: note.timestamp))!
            if weeklyNotes[weekStart] == nil {
                weeklyNotes[weekStart] = []
            }
            weeklyNotes[weekStart]?.append(note)
        }

        var currentStreak = 0
        var checkWeek = currentWeekStart

        // Count backwards from current week until we find a week with no notes
        while let _ = weeklyNotes[checkWeek] {
            currentStreak += 1
            checkWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: checkWeek)!
        }

        return currentStreak
    }

    @MainActor func postNote(content: String, formatting: [Note.TextFormatting]) async throws {
        guard let authViewModel = authViewModel else { throw URLError(.userAuthenticationRequired) }
        let url = "http://34.21.62.193/api/posts/"
        let token = try await authViewModel.getAuthToken()
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        let parameters: [String: Any] = [
            "content": content,
            "formatting": formatting.map { formatting in
                [
                    "type": formatting.type.rawValue,
                    "range": [
                        "location": formatting.range.location,
                        "length": formatting.range.length
                    ]
                ]
            }
        ]
        _ = try await AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers)
            .serializingDecodable(CreateNoteResponse.self)
            .value

        await self.fetchNotes()
    }
}

extension Date {
    var startOfWeek: Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
