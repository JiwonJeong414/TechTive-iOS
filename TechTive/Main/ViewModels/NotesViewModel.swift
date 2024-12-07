//
//  NotesViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI
import Alamofire

struct NotesResponse: Codable {
    let posts: [Note]
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    private let authViewModel = AuthViewModel()
    
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
    
    func fetchNotes() async {
        do {
            let url = URL(string: "https://631c-128-84-124-32.ngrok-free.app/api/posts/")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(try await authViewModel.getAuthToken())", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(NotesResponse.self, from: data)
            DispatchQueue.main.async {
                self.notes = response.posts
            }
        } catch {
            print("Error fetching notes: \(error)")
        }
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
