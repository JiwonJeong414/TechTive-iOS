//
//  AddNoteView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI
import Alamofire

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var attributedText: NSAttributedString
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var isLoading = false
    @State private var error: String?
    @ObservedObject var viewModel: NotesViewModel
    let isEditing: Bool
    private let originalNote: Note?

    init(viewModel: NotesViewModel, note: Note? = nil) {
        self.viewModel = viewModel
        self.isEditing = note != nil
        self.originalNote = note

        if let note = note {
            let normalizedText = NSMutableAttributedString(attributedString: note.toAttributedString())
            normalizedText.enumerateAttributes(in: NSRange(location: 0, length: normalizedText.length), options: []) { attributes, range, _ in
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
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { attributes, range, _ in
            if let font = attributes[.font] as? UIFont {
                if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    formattingArray.append(Note.TextFormatting(
                        type: .bold,
                        range: .init(location: range.location, length: range.length)
                    ))
                }
                if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    formattingArray.append(Note.TextFormatting(
                        type: .italic,
                        range: .init(location: range.location, length: range.length)
                    ))
                }
                if font.pointSize >= 24 {
                    formattingArray.append(Note.TextFormatting(
                        type: .header,
                        range: .init(location: range.location, length: range.length)
                    ))
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

        let _ = try await AF.request(url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers)
            .serializingDecodable(CreateNoteResponse.self)
            .value

        await MainActor.run {
            dismiss()
        }

        try? await Task.sleep(for: .seconds(0.5))
        await viewModel.fetchNotes()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { toggleHeader() }) {
                        Image(systemName: "textformat.size.larger")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    Button(action: { toggleBold() }) {
                        Image(systemName: "bold")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    Button(action: { toggleItalic() }) {
                        Image(systemName: "italic")
                            .foregroundColor(Color(UIColor.color.orange))
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

                FormattedTextView(attributedText: $attributedText, selectedRange: $selectedRange)
                    .background(Color(UIColor.color.lightYellow))
                    .cornerRadius(12)
                    .padding()
            }
            .background(Color(UIColor.color.lightYellow).opacity(0.3))
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(UIColor.color.orange))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        isLoading = true
                        error = nil

                        Task {
                            do {
                                try await postNote()
                                await MainActor.run {
                                    dismiss()
                                }
                            } catch {
                                await MainActor.run {
                                    self.error = "Failed to post note: \(error.localizedDescription)"
                                    isLoading = false
                                }
                            }
                        }
                    }
                    .foregroundColor(Color(UIColor.color.orange))
                    .disabled(isLoading || attributedText.string.isEmpty)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.4))
                }
            }
        }
    }

    private func toggleHeader() {
        guard selectedRange.length > 0 else { return }

        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)

        var isCurrentlyHeader = false
        if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyHeader = font.pointSize >= 24
        }

        let newFont = isCurrentlyHeader
        ? UIFont.systemFont(ofSize: 17)
        : UIFont.systemFont(ofSize: 24, weight: .bold)

        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }

    private func toggleBold() {
        guard selectedRange.length > 0 else { return }

        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)

        var isCurrentlyBold = false
        if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
        }

        let newFont = isCurrentlyBold
        ? UIFont.systemFont(ofSize: 17)
        : UIFont.boldSystemFont(ofSize: 17)

        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }

    private func toggleItalic() {
        guard selectedRange.length > 0 else { return }

        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)

        var isCurrentlyItalic = false
        if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
        }

        let newFont = isCurrentlyItalic
        ? UIFont.systemFont(ofSize: 17)
        : UIFont.italicSystemFont(ofSize: 17)

        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }
}

#Preview {
    AddNoteView(viewModel: NotesViewModel())
        .environmentObject(AuthViewModel())
}
