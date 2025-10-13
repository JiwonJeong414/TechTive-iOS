import SwiftUI

struct Note: Identifiable, Codable {
    let id: Int
    let content: String
    let timestamp: Date
    let userID: Int?
    let formattings: [TextFormatting]

    let angerValue: Double
    let disgustValue: Double
    let fearValue: Double
    let joyValue: Double
    let neutralValue: Double
    let sadnessValue: Double
    let surpriseValue: Double

    struct TextFormatting: Codable {
        let type: FormattingType
        let location: Int
        let length: Int

        enum FormattingType: String, Codable {
            case header = "HEADER"
            case bold = "BOLD"
            case italic = "ITALIC"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case timestamp = "created_at"
        case userID = "user_id"
        case formattings
        case angerValue = "anger_value"
        case disgustValue = "disgust_value"
        case fearValue = "fear_value"
        case joyValue = "joy_value"
        case neutralValue = "neutral_value"
        case sadnessValue = "sadness_value"
        case surpriseValue = "surprise_value"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
        self.userID = try container.decodeIfPresent(Int.self, forKey: .userID)
        self.formattings = try container.decodeIfPresent([TextFormatting].self, forKey: .formattings) ?? []

        // Make emotion values optional with default values
        self.angerValue = try container.decodeIfPresent(Double.self, forKey: .angerValue) ?? 0.0
        self.disgustValue = try container.decodeIfPresent(Double.self, forKey: .disgustValue) ?? 0.0
        self.fearValue = try container.decodeIfPresent(Double.self, forKey: .fearValue) ?? 0.0
        self.joyValue = try container.decodeIfPresent(Double.self, forKey: .joyValue) ?? 0.0
        self.neutralValue = try container.decodeIfPresent(Double.self, forKey: .neutralValue) ?? 1.0
        self.sadnessValue = try container.decodeIfPresent(Double.self, forKey: .sadnessValue) ?? 0.0
        self.surpriseValue = try container.decodeIfPresent(Double.self, forKey: .surpriseValue) ?? 0.0

        // Handle timestamp as string and convert to Date
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestampString) {
            self.timestamp = date
        } else {
            // Fallback to current date if parsing fails
            self.timestamp = Date()
        }
    }
}

extension Note {
    func toAttributedString() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: content)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: self.content.count))

        for format in self.formattings {
            // Validate the formatting range
            let start = format.location
            let end = start + format.length
            guard start >= 0, end <= self.content.count else {
                // Skip this formatting if it's invalid
                continue
            }

            let nsRange = NSRange(location: start, length: format.length)

            switch format.type {
                case .header:
                    attributedString.addAttribute(
                        .font,
                        value: UIFont.systemFont(ofSize: 24, weight: .bold),
                        range: nsRange)
                case .bold:
                    attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: nsRange)
                case .italic:
                    attributedString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 17), range: nsRange)
            }
        }

        return attributedString
    }

    var dominantEmotion: (emotion: String, value: Double) {
        let emotions: [(String, Double)] = [
            ("Anger", angerValue),
            ("Disgust", disgustValue),
            ("Fear", fearValue),
            ("Joy", joyValue),
            ("Neutral", neutralValue),
            ("Sadness", sadnessValue),
            ("Surprise", surpriseValue)
        ]

        return emotions.max(by: { $0.1 < $1.1 }) ?? ("Neutral", 0)
    }
}
