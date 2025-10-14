import Foundation

struct UserProfile {
    let id: String
    let name: String
}

struct ProfilePictureResponse: Codable {
    let message: String?
    let url: String?
    let filename: String?

    // Alternative field names for GET requests
    private let profilePictureUrl: String?

    // Computed property to get the actual URL
    var imageURL: String? {
        return self.profilePictureUrl ?? self.url
    }

    enum CodingKeys: String, CodingKey {
        case message
        case url
        case filename
        case profilePictureUrl = "profile_picture_url"
    }
}
