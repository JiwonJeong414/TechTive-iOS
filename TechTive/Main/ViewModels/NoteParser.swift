//
//  NoteParser.swift
//  TechTive
//
//  Created by jiwon jeong on 11/27/24.
//

import Foundation
import SwiftUI

struct FormattedText {
    let type: FormattingType
    let content: String
}

enum FormattingType {
    case plainText
    case heading1
    case heading2
    case bullet
    case code
    
    var fontStyle: Font {
        switch self {
        case .plainText: return .body
        case .heading1: return .title
        case .heading2: return .title2
        case .bullet: return .body
        case .code: return .system(.body, design: .monospaced)
        }
    }
}

class NoteParser {
    static func parse(_ text: String) -> [FormattedText] {
        var formattedTexts: [FormattedText] = []
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            if line.starts(with: "h1{") && line.hasSuffix("}") {
                let content = String(line.dropFirst(3).dropLast())
                formattedTexts.append(FormattedText(type: .heading1, content: content))
            } else if line.starts(with: "h2{") && line.hasSuffix("}") {
                let content = String(line.dropFirst(3).dropLast())
                formattedTexts.append(FormattedText(type: .heading2, content: content))
            } else if line.starts(with: "bullet{") && line.hasSuffix("}") {
                let content = String(line.dropFirst(7).dropLast())
                formattedTexts.append(FormattedText(type: .bullet, content: content))
            } else if line.starts(with: "code{") && line.hasSuffix("}") {
                let content = String(line.dropFirst(5).dropLast())
                formattedTexts.append(FormattedText(type: .code, content: content))
            } else {
                formattedTexts.append(FormattedText(type: .plainText, content: line))
            }
        }
        
        return formattedTexts
    }
}
