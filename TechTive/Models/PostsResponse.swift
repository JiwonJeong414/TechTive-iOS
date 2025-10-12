import Foundation

struct PostsResponse: Codable {
    let message: String
    let posts: [Note]
}

struct PostResponse: Codable {
    let message: String
    let post: Note
}
