import SwiftUI

extension AddNotesView {
    @MainActor class ViewModel: ObservableObject {
        // MARK: - Properties

        @Published var attributedText: NSAttributedString
        @Published var selectedRange = NSRange(location: 0, length: 0)
        @Published var isLoading = false
        @Published var error: String?
        let note: Note?
        let isEditing: Bool
        let originalNote: Note?

        // MARK: - Init

        init(note: Note? = nil) {
            self.note = note
            self.isEditing = note != nil
            self.originalNote = note
            if let note = note {
                let normalizedText = NSMutableAttributedString(attributedString: note.toAttributedString())
                normalizedText.enumerateAttributes(
                    in: NSRange(location: 0, length: normalizedText.length),
                    options: [])
                { attributes, range, _ in
                    if attributes[.font] == nil {
                        normalizedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: range)
                    }
                }
                self.attributedText = normalizedText
            } else {
                self.attributedText = NSMutableAttributedString(
                    string: "",
                    attributes: [.font: UIFont.systemFont(ofSize: 17)])
            }
        }

        // MARK: - Helpers

        func postNote(notesViewModel: NotesViewModel, dismiss: @escaping () -> Void) async {
            var formattingArray: [Note.TextFormatting] = []
            self.attributedText.enumerateAttributes(
                in: NSRange(location: 0, length: self.attributedText.length))
            { attributes, range, _ in
                if let font = attributes[.font] as? UIFont {
                    if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                        formattingArray.append(Note.TextFormatting(
                            type: .bold,
                            range: .init(location: range.location, length: range.length)))
                    }
                    if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                        formattingArray.append(Note.TextFormatting(
                            type: .italic,
                            range: .init(location: range.location, length: range.length)))
                    }
                    if font.pointSize >= 24 {
                        formattingArray.append(Note.TextFormatting(
                            type: .header,
                            range: .init(location: range.location, length: range.length)))
                    }
                }
            }
            do {
                try await notesViewModel.postNote(content: self.attributedText.string, formatting: formattingArray)
                dismiss()
            } catch {
                self.error = "Failed to post note: \(error.localizedDescription)"
            }
        }

        func toggleHeader() {
            guard self.selectedRange.length > 0 else { return }
            let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
            var isCurrentlyHeader = false
            if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
                isCurrentlyHeader = font.pointSize >= 24
            }
            let newFont = isCurrentlyHeader
                ? UIFont.systemFont(ofSize: 17)
                : UIFont.systemFont(ofSize: 24, weight: .bold)
            mutableAttrString.addAttribute(.font, value: newFont, range: self.selectedRange)
            self.attributedText = mutableAttrString
        }

        func toggleBold() {
            guard self.selectedRange.length > 0 else { return }
            let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
            var isCurrentlyBold = false
            if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
                isCurrentlyBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
            }
            let newFont = isCurrentlyBold
                ? UIFont.systemFont(ofSize: 17)
                : UIFont.boldSystemFont(ofSize: 17)
            mutableAttrString.addAttribute(.font, value: newFont, range: self.selectedRange)
            self.attributedText = mutableAttrString
        }

        func toggleItalic() {
            guard self.selectedRange.length > 0 else { return }
            let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
            var isCurrentlyItalic = false
            if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
                isCurrentlyItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            }
            let newFont = isCurrentlyItalic
                ? UIFont.systemFont(ofSize: 17)
                : UIFont.italicSystemFont(ofSize: 17)
            mutableAttrString.addAttribute(.font, value: newFont, range: self.selectedRange)
            self.attributedText = mutableAttrString
        }
    }
}
