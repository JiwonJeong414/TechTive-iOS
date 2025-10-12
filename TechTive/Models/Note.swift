import SwiftUI

struct Note: Identifiable, Codable {
    let id: Int
    let content: String
    let timestamp: Date
    let userID: Int
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
            case header
            case bold
            case italic
            case underline
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
                case .underline:
                    attributedString.addAttribute(
                        .underlineStyle,
                        value: NSUnderlineStyle.single.rawValue,
                        range: nsRange)
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
