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
    
    init(id: UUID = UUID(), content: String, userId: String, formatting: [TextFormatting] = []) {
        self.id = id
        self.content = content
        self.timestamp = Date() // Automatically sets the creation timestamp
        self.userId = userId
        self.formatting = formatting
    }
}

// Extension for additional functionality related to NSAttributedString
extension Note {
    init(attributedString: NSAttributedString, userId: String, id: UUID = UUID()) {
        let plainText = attributedString.string
        var formatting: [TextFormatting] = []
        
        // Enumerate through all attributes in the attributed string
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length)) { attributes, range, _ in
            if let font = attributes[.font] as? UIFont {
                // Check for header
                if font.pointSize >= 24 {
                    formatting.append(TextFormatting(
                        type: .header,
                        range: TextFormatting.Range(
                            location: range.location,
                            length: range.length
                        )
                    ))
                }
                // this should else if because header is already bold
                else if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    formatting.append(TextFormatting(
                        type: .bold,
                        range: TextFormatting.Range(
                            location: range.location,
                            length: range.length
                        )
                    ))
                }
                
                // Check for italic
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
        
        // Set properties for the new `Note` object
        self.id = id
        self.content = plainText
        self.timestamp = Date()
        self.userId = userId
        self.formatting = formatting
    }
    
    // Convert the `Note` back into an `NSAttributedString` with formatting applied
    func toAttributedString() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: content)
        
        // Apply basic paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: content.count)
        )
        
        // Apply saved formatting
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
}
