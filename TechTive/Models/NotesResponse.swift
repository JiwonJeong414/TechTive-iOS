import Foundation

/// Response model for notes API
struct NotesResponse: Codable {
    let posts: [Note]
}
