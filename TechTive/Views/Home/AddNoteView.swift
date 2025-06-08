import Alamofire
import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: NotesViewModel

    @State private var attributedText: NSAttributedString
    @State private var selectedRange = NSRange(location: 0, length: 0)
    @State private var isLoading = false
    @State private var error: String?
    let note: Note?
    let isEditing: Bool
    private let originalNote: Note?

    init(note: Note? = nil) {
        self.note = note
        self.isEditing = note != nil
        self.originalNote = note

        if let note = note {
            let normalizedText = NSMutableAttributedString(attributedString: note.toAttributedString())
            normalizedText
                .enumerateAttributes(
                    in: NSRange(location: 0, length: normalizedText.length),
                    options: [])
                { attributes, range, _ in
                    if attributes[.font] == nil {
                        normalizedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: range)
                    }
                }
            _attributedText = State(initialValue: normalizedText)
        } else {
            let defaultText = NSMutableAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 17)])
            _attributedText = State(initialValue: defaultText)
        }
    }

    private func postNote() async throws {
        print("hello")
        let url = "http://34.21.62.193/api/posts/"

        let token = try await authViewModel.getAuthToken()
        print("token: " + token)

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)"
        ]

        var formattingArray: [Note.TextFormatting] = []
        self.attributedText.enumerateAttributes(in: NSRange(
            location: 0,
            length: self.attributedText.length))
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

        let parameters: [String: Any] = [
            "content": attributedText.string,
            "formatting": formattingArray.map { formatting in
                [
                    "type": formatting.type.rawValue,
                    "range": [
                        "location": formatting.range.location,
                        "length": formatting.range.length
                    ]
                ]
            }
        ]

        print("📍 DEBUG - Request URL: \(url)")
        print("📍 DEBUG - Request Headers: \(headers)")

        let _ = try await AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers)
            .serializingDecodable(CreateNoteResponse.self)
            .value

        await MainActor.run {
            self.dismiss()
        }

        try? await Task.sleep(for: .seconds(0.5))
        await self.viewModel.fetchNotes()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { self.toggleHeader() }) {
                        Image(systemName: "textformat.size.larger")
                            .foregroundColor(Color(Constants.Colors.orange))
                    }
                    Button(action: { self.toggleBold() }) {
                        Image(systemName: "bold")
                            .foregroundColor(Color(Constants.Colors.orange))
                    }
                    Button(action: { self.toggleItalic() }) {
                        Image(systemName: "italic")
                            .foregroundColor(Color(Constants.Colors.orange))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                Divider()
                    .background(Color.orange)

                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                FormattedTextView(attributedText: self.$attributedText, selectedRange: self.$selectedRange)
                    .background(Color(Constants.Colors.lightYellow))
                    .cornerRadius(12)
                    .padding()
            }
            .background(Color(Constants.Colors.lightYellow).opacity(0.3))
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        self.dismiss()
                    }
                    .foregroundColor(Color(Constants.Colors.orange))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        self.isLoading = true
                        self.error = nil

                        Task {
                            do {
                                try await self.postNote()
                                await MainActor.run {
                                    self.dismiss()
                                }
                            } catch {
                                await MainActor.run {
                                    self.error = "Failed to post note: \(error.localizedDescription)"
                                    self.isLoading = false
                                }
                            }
                        }
                    }
                    .foregroundColor(Color(Constants.Colors.orange))
                    .disabled(self.isLoading || self.attributedText.string.isEmpty)
                }
            }
            .overlay {
                if self.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.4))
                }
            }
        }
    }

    private func toggleHeader() {
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

    private func toggleBold() {
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

    private func toggleItalic() {
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
