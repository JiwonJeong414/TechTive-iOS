import Foundation

struct ProfilePictureResponse: Codable {
    let message: String
    let link: String?

    // Alternative field names that might be used by the API
    private let url: String?
    private let imageUrl: String?
    private let profilePictureUrl: String?

    // Computed property to get the actual URL
    var imageURL: String? {
        return self.link ?? self.url ?? self.imageUrl ?? self.profilePictureUrl
    }

    enum CodingKeys: String, CodingKey {
        case message
        case link
        case url
        case imageUrl = "image_url"
        case profilePictureUrl = "profile_picture_url"
    }
}
