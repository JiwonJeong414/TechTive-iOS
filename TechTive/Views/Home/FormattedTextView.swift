import SwiftUI

struct FormattedTextView: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var selectedRange: NSRange

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        textView.font = UIFont.systemFont(ofSize: 17)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context _: Context) {
        if uiView.attributedText != self.attributedText {
            uiView.attributedText = self.attributedText
        }
        if uiView.selectedRange != self.selectedRange {
            uiView.selectedRange = self.selectedRange
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(attributedText: self.$attributedText, selectedRange: self.$selectedRange)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var attributedText: Binding<NSAttributedString>
        var selectedRange: Binding<NSRange>

        init(attributedText: Binding<NSAttributedString>, selectedRange: Binding<NSRange>) {
            self.attributedText = attributedText
            self.selectedRange = selectedRange
        }

        func textViewDidChange(_ textView: UITextView) {
            self.attributedText.wrappedValue = textView.attributedText
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            self.selectedRange.wrappedValue = textView.selectedRange
        }
    }
}
