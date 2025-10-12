import Foundation

/// Response model for notes API
struct NotesResponse: Codable {
    let notes: [Note]
}

/// Response model for individual note API
struct NoteResponse: Codable {
    let note: Note
}
