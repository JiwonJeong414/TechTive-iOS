//
//  FormattedTextView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/27/24.
//

import SwiftUI
import UIKit

struct FormattedTextView: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var selectedRange: NSRange
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        textView.font = UIFont.systemFont(ofSize: 12)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.attributedText != attributedText {
            uiView.attributedText = attributedText
        }
        if uiView.selectedRange != selectedRange {
            uiView.selectedRange = selectedRange
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(attributedText: $attributedText, selectedRange: $selectedRange)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var attributedText: Binding<NSAttributedString>
        var selectedRange: Binding<NSRange>
        
        init(attributedText: Binding<NSAttributedString>, selectedRange: Binding<NSRange>) {
            self.attributedText = attributedText
            self.selectedRange = selectedRange
        }
        
        func textViewDidChange(_ textView: UITextView) {
            attributedText.wrappedValue = textView.attributedText
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            selectedRange.wrappedValue = textView.selectedRange
        }
    }
}
