//
//  Note.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI

struct CreateNoteResponse: Codable {
    let post: Note
    let message: String
}

struct Note: Identifiable, Codable {
    let id: Int
    let content: String
    let timestamp: Date
    let userID: Int // Changed from userId to userID to match the JSON key
    let formatting: [TextFormatting]
    
    let angerValue: Double
    let disgustValue: Double
    let fearValue: Double
    let joyValue: Double
    let neutralValue: Double
    let sadnessValue: Double
    let surpriseValue: Double
    
    struct TextFormatting: Codable {
        let type: FormattingType
        let range: Range
        
        struct Range: Codable {
            let location: Int
            let length: Int
        }
        
        enum FormattingType: String, Codable {
            case header
            case bold
            case italic
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case timestamp = "created_at"
        case userID = "user_id" // Updated to match the JSON key
        case formatting
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
        
        // Decode timestamp
        let dateString = try container.decode(String.self, forKey: .timestamp)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            self.timestamp = date
        } else {
            // If the first formatter fails, try a backup format
            let backupFormatter = DateFormatter()
            backupFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = backupFormatter.date(from: dateString) {
                self.timestamp = date
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .timestamp,
                    in: container,
                    debugDescription: "Date string \(dateString) does not match expected format"
                )
            }
        }
        
        // Decode userID
        if let userIDString = try? container.decode(String.self, forKey: .userID) {
            self.userID = Int(userIDString) ?? 0
        } else {
            self.userID = 0
        }
        
        self.formatting = try container.decode([TextFormatting].self, forKey: .formatting)
        
        // Decode emotion values, handling missing keys
        self.angerValue = try container.decodeIfPresent(Double.self, forKey: .angerValue) ?? 0.0
        self.disgustValue = try container.decodeIfPresent(Double.self, forKey: .disgustValue) ?? 0.0
        self.fearValue = try container.decodeIfPresent(Double.self, forKey: .fearValue) ?? 0.0
        self.joyValue = try container.decodeIfPresent(Double.self, forKey: .joyValue) ?? 0.0
        self.neutralValue = try container.decodeIfPresent(Double.self, forKey: .neutralValue) ?? 0.0
        self.sadnessValue = try container.decodeIfPresent(Double.self, forKey: .sadnessValue) ?? 0.0
        self.surpriseValue = try container.decodeIfPresent(Double.self, forKey: .surpriseValue) ?? 0.0
    }
    
    init(id: Int = 0,
         content: String,
         userID: Int = 0,
         formatting: [TextFormatting] = [],
         angerValue: Double = 0,
         disgustValue: Double = 0,
         fearValue: Double = 0,
         joyValue: Double = 0,
         neutralValue: Double = 0,
         sadnessValue: Double = 0,
         surpriseValue: Double = 0) {
        
        self.id = id
        self.content = content
        self.timestamp = Date()
        self.userID = userID
        self.formatting = formatting
        self.angerValue = angerValue
        self.disgustValue = disgustValue
        self.fearValue = fearValue
        self.joyValue = joyValue
        self.neutralValue = neutralValue
        self.sadnessValue = sadnessValue
        self.surpriseValue = surpriseValue
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
            range: NSRange(location: 0, length: content.count)
        )
        
        for format in formatting {
            // Validate the formatting range
            let start = format.range.location
            let end = start + format.range.length
            guard start >= 0, end <= content.count else {
                // Skip this formatting if it's invalid
                continue
            }
            
            let nsRange = NSRange(location: start, length: format.range.length)
            
            switch format.type {
            case .header:
                attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24, weight: .bold), range: nsRange)
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
