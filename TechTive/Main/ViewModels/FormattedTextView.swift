import SwiftUI
import UIKit

struct FormattedTextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 17)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let attributedString = NSMutableAttributedString()
        let lines = text.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            var attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 17)
            ]
            
            if line.hasPrefix("#") {
                // Hide the # by making it transparent
                let hashMark = NSAttributedString(
                    string: "#",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 30, weight: .bold),
                        .foregroundColor: UIColor.clear
                    ]
                )
                attributedString.append(hashMark)
                
                // Show the rest of the line in large bold font
                let restOfLine = NSAttributedString(
                    string: String(line.dropFirst()),
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 30, weight: .bold),
                        .foregroundColor: UIColor.label
                    ]
                )
                attributedString.append(restOfLine)
            } else {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 8
                attributes[.paragraphStyle] = paragraphStyle
                
                attributedString.append(NSAttributedString(string: line, attributes: attributes))
            }
            
            if index < lines.count - 1 {
                attributedString.append(NSAttributedString(string: "\n"))
            }
        }
        
        let selectedRange = uiView.selectedRange
        uiView.attributedText = attributedString
        uiView.selectedRange = selectedRange
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        
        init(text: Binding<String>) {
            self.text = text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
        }
    }
}
