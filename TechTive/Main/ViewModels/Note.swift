//
//  Note.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct CreateNoteResponse: Codable {
    let post: Note
    let formatting: [Note.TextFormatting]
    let message: String
}

struct Note: Identifiable, Codable {
    let id: Int
    let content: String
    let timestamp: Date
    let userId: Int
    let formatting: [TextFormatting]
    
    // Adding emotion values
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
        
        // Defines a specific range in the text
        struct Range: Codable {
            let location: Int // Starting position of the range
            let length: Int // Length of the range
        }
        
        // Enum defining possible formatting types
        enum FormattingType: String, Codable {
            case header
            case bold
            case italic
        }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle required fields
        self.id = try container.decode(Int.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
        
        // Handle timestamp with fallback
        if let timestamp = try? container.decode(Date.self, forKey: .timestamp) {
            self.timestamp = timestamp
        } else {
            self.timestamp = Date()
        }
        
        // Handle userId with fallback
        self.userId = try container.decodeIfPresent(Int.self, forKey: .userId) ?? 0
        
        // Handle formatting with fallback
        self.formatting = (try? container.decode([TextFormatting].self, forKey: .formatting)) ?? []
        
        // Handle optional emotion values with fallbacks
        let decodeDouble: (String) -> Double = { stringValue in
            return Double(stringValue) ?? 0.0
        }
        
        // Make all emotion values optional with default 0
        if let angerString = try? container.decode(String.self, forKey: .angerValue) {
            self.angerValue = decodeDouble(angerString)
        } else {
            self.angerValue = try container.decodeIfPresent(Double.self, forKey: .angerValue) ?? 0.0
        }
        
        if let disgustString = try? container.decode(String.self, forKey: .disgustValue) {
            self.disgustValue = decodeDouble(disgustString)
        } else {
            self.disgustValue = try container.decodeIfPresent(Double.self, forKey: .disgustValue) ?? 0.0
        }
        
        if let fearString = try? container.decode(String.self, forKey: .fearValue) {
            self.fearValue = decodeDouble(fearString)
        } else {
            self.fearValue = try container.decodeIfPresent(Double.self, forKey: .fearValue) ?? 0.0
        }
        
        if let joyString = try? container.decode(String.self, forKey: .joyValue) {
            self.joyValue = decodeDouble(joyString)
        } else {
            self.joyValue = try container.decodeIfPresent(Double.self, forKey: .joyValue) ?? 0.0
        }
        
        if let neutralString = try? container.decode(String.self, forKey: .neutralValue) {
            self.neutralValue = decodeDouble(neutralString)
        } else {
            self.neutralValue = try container.decodeIfPresent(Double.self, forKey: .neutralValue) ?? 0.0
        }
        
        if let sadnessString = try? container.decode(String.self, forKey: .sadnessValue) {
            self.sadnessValue = decodeDouble(sadnessString)
        } else {
            self.sadnessValue = try container.decodeIfPresent(Double.self, forKey: .sadnessValue) ?? 0.0
        }
        
        if let surpriseString = try? container.decode(String.self, forKey: .surpriseValue) {
            self.surpriseValue = decodeDouble(surpriseString)
        } else {
            self.surpriseValue = try container.decodeIfPresent(Double.self, forKey: .surpriseValue) ?? 0.0
        }
    }
    init(id: Int = 0,  // Changed from String
         content: String,
         userId: Int = 0,  // Changed from String
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
        self.userId = userId
        self.formatting = formatting
        self.angerValue = angerValue
        self.disgustValue = disgustValue
        self.fearValue = fearValue
        self.joyValue = joyValue
        self.neutralValue = neutralValue
        self.sadnessValue = sadnessValue
        self.surpriseValue = surpriseValue
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case timestamp = "created_at"
        case userId = "user_id"
        case formatting
        case angerValue = "anger_value"
        case disgustValue = "disgust_value"
        case fearValue = "fear_value"
        case joyValue = "joy_value"
        case neutralValue = "neutral_value"
        case sadnessValue = "sadness_value"
        case surpriseValue = "surprise_value"
    }
}

// Extension for additional functionality related to NSAttributedString
extension Note {
    init(attributedString: NSAttributedString, userId: String, id: UUID = UUID()) {
        let plainText = attributedString.string
        var formatting: [TextFormatting] = []
        
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length)) { attributes, range, _ in
            if let font = attributes[.font] as? UIFont {
                if font.pointSize >= 24 {
                    formatting.append(TextFormatting(
                        type: .header,
                        range: TextFormatting.Range(
                            location: range.location,
                            length: range.length
                        )
                    ))
                } else if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    formatting.append(TextFormatting(
                        type: .bold,
                        range: TextFormatting.Range(
                            location: range.location,
                            length: range.length
                        )
                    ))
                }
                
                if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    formatting.append(TextFormatting(
                        type: .italic,
                        range: TextFormatting.Range(
                            location: range.location,
                            length: range.length
                        )
                    ))
                }
            }
        }
        
        
        self.init(
            id: 0,  // Default to 0 for new notes
            content: plainText,
            userId: Int(userId) ?? 0,  // Convert String userId to Int
            formatting: formatting,
            angerValue: 0,
            disgustValue: 0,
            fearValue: 0,
            joyValue: 0,
            neutralValue: 0,
            sadnessValue: 0,
            surpriseValue: 0
        )
    }
    
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
            let nsRange = NSRange(location: format.range.location, length: format.range.length)
            
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
    
    // Helper to get dominant emotion
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
