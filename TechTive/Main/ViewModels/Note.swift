//
//  Note.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct Note: Identifiable, Codable {
    let id: UUID
    let content: String
    let timestamp: Date
    let userId: String
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
    
    init(id: UUID = UUID(),
         content: String,
         userId: String,
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
            id: id,
            content: plainText,
            userId: userId,
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
