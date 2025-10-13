import Foundation

/// Response model for notes API - matches actual backend response
struct NotesResponse: Codable {
    let notes: [Note]
}

/// Individual note API returns the note directly, not wrapped
/// So we can use Note directly for individual note responses
