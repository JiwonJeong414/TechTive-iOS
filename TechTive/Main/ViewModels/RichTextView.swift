//
//  RichTextView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/27/24.
//

import SwiftUI
import UIKit

struct RichTextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Create attributed string from current text
        let attributedString = NSMutableAttributedString()
        let paragraphs = text.components(separatedBy: .newlines)
        
        // Process each paragraph
        for (index, paragraph) in paragraphs.enumerated() {
            var paragraphText = paragraph
            var attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16)
            ]
            
            // Check for formatting markers and apply appropriate styling
            if paragraph.hasPrefix("# ") {
                paragraphText = String(paragraph.dropFirst(2))
                attributes[.font] = UIFont.systemFont(ofSize: 28, weight: .bold)
            }
            
            // Add the formatted paragraph
            let formattedString = NSAttributedString(string: paragraphText, attributes: attributes)
            attributedString.append(formattedString)
            
            // Add newline if not the last paragraph
            if index < paragraphs.count - 1 {
                attributedString.append(NSAttributedString(string: "\n"))
            }
        }
        
        // Update text view if content has changed
        if uiView.attributedText != attributedString {
            let selectedRange = uiView.selectedRange
            uiView.attributedText = attributedString
            uiView.selectedRange = selectedRange
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextView
        
        init(_ parent: RichTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
