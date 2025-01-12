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
    @Published var isLoading = false
    @Published var error: Error?
    
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
        
        return weeklyCounts.reversed()
    }
    
    func fetchNotes() async {
        do {
            let url = "http://34.21.62.193/api/posts/"
            let token = try await authViewModel.getAuthToken()
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)"
            ]
            
            let response = try await AF.request(url,
                                              method: .get,
                                              headers: headers)
                .serializingDecodable(NotesResponse.self)
                .value
                
            await MainActor.run {
                // Sort the posts with newest first
                self.notes = response.posts.sorted {
                    $0.timestamp > $1.timestamp
                }
            }
        } catch {
            print("Error fetching notes: \(error)")
        }
    }
    
    // Call this after successfully posting a new note
    func addNewNote(_ note: Note) {
        notes.insert(note, at: 0) // Insert at the beginning since it's newest
        saveNotes()
        
        // Refresh notes in the background
        Task {
            await fetchNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
            saveNotes()
            
            // Sync with server after local deletion
            Task {
                await fetchNotes()
            }
        }
    }
    
    func updateNote(_ updatedNote: Note) {
        if let index = notes.firstIndex(where: { $0.id == updatedNote.id }) {
            notes[index] = updatedNote
            saveNotes()
            
            // Sync with server after local update
            Task {
                await fetchNotes()
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
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedNotes) {
            notes = decodedNotes
        }
    }
    
    init() {
        loadNotes()
        // Fetch fresh data on init
        Task {
            await fetchNotes()
        }
    }
}

extension Date {
    var startOfWeek: Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
