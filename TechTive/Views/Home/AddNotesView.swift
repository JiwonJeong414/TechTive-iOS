//
//  AddNotesView.swift
//  TechTive
//
//  View for adding or editing a note
//

import SwiftUI

struct AddNotesView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notesViewModel: NotesViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var attributedText: NSAttributedString
    @State private var selectedRange = NSRange(location: 0, length: 0)
    @State private var isLoading = false
    @State private var error: String?
    
    let note: Note?
    let isEditing: Bool
    
    // MARK: - Initialization
    
    init(note: Note? = nil) {
        self.note = note
        self.isEditing = note != nil
        
        if let note = note {
            let normalizedText = NSMutableAttributedString(attributedString: note.toAttributedString())
            normalizedText.enumerateAttributes(
                in: NSRange(location: 0, length: normalizedText.length),
                options: []
            ) { attributes, range, _ in
                if attributes[.font] == nil {
                    normalizedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: range)
                }
            }
            _attributedText = State(initialValue: normalizedText)
        } else {
            _attributedText = State(initialValue: NSMutableAttributedString(
                string: "",
                attributes: [.font: UIFont.systemFont(ofSize: 17)]
            ))
        }
    }
    
    // MARK: - UI
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                formattingToolbar
                Divider().background(Color(Constants.Colors.orange))
                errorSection
                textEditorSection
            }
            .background(Color(Constants.Colors.lightYellow).opacity(0.3))
            .navigationTitle(isEditing ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(Constants.Colors.orange))
                }
                
                if isEditing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { Task { await deleteNote() } }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .disabled(isLoading)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Post") {
                        Task { await postNote() }
                    }
                    .foregroundColor(Color(Constants.Colors.orange))
                    .disabled(isLoading || attributedText.string.isEmpty)
                }
            }
            .overlay(loadingOverlay)
        }
    }
    
    // MARK: - Components
    
    private var formattingToolbar: some View {
        HStack(spacing: 16) {
            Button(action: { toggleHeader() }) {
                Image(systemName: "textformat.size.larger")
                    .foregroundColor(selectedRange.length > 0 ? Color(Constants.Colors.orange) : Color.gray)
            }
            .disabled(selectedRange.length == 0)
            
            Button(action: { toggleBold() }) {
                Image(systemName: "bold")
                    .foregroundColor(selectedRange.length > 0 ? Color(Constants.Colors.orange) : Color.gray)
            }
            .disabled(selectedRange.length == 0)
            
            Button(action: { toggleItalic() }) {
                Image(systemName: "italic")
                    .foregroundColor(selectedRange.length > 0 ? Color(Constants.Colors.orange) : Color.gray)
            }
            .disabled(selectedRange.length == 0)
            
            Spacer()
            
            Text("Select text to format")
                .font(.caption)
                .foregroundColor(.gray)
                .opacity(selectedRange.length == 0 ? 1.0 : 0.0)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var errorSection: some View {
        Group {
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private var textEditorSection: some View {
        FormattedTextView(attributedText: $attributedText, selectedRange: $selectedRange)
            .background(Color(Constants.Colors.lightYellow))
            .cornerRadius(12)
            .padding()
    }
    
    private var loadingOverlay: some View {
        Group {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(Constants.Colors.black).opacity(0.4))
            }
        }
    }
    
    // MARK: - Methods
    
    private func postNote() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        var formattingArray: [Note.TextFormatting] = []
        attributedText.enumerateAttributes(
            in: NSRange(location: 0, length: attributedText.length)
        ) { attributes, range, _ in
            if let font = attributes[.font] as? UIFont {
                if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    formattingArray.append(Note.TextFormatting(
                        type: .bold,
                        location: range.location,
                        length: range.length
                    ))
                }
                if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    formattingArray.append(Note.TextFormatting(
                        type: .italic,
                        location: range.location,
                        length: range.length
                    ))
                }
                if font.pointSize >= 24 {
                    formattingArray.append(Note.TextFormatting(
                        type: .header,
                        location: range.location,
                        length: range.length
                    ))
                }
            }
        }
        
        do {
            try await notesViewModel.createNote(
                content: attributedText.string,
                formattings: formattingArray
            )
            
            await MainActor.run {
                isLoading = false
                error = nil
                dismiss()
            }
        } catch let postError {  // ✅ Renamed to avoid collision
            await MainActor.run {
                isLoading = false
                error = "Failed to post note: \(postError.localizedDescription)"
                print("❌ Error posting note: \(postError)")
            }
        }
    }
    
    private func deleteNote() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        guard let note = note else {
            await MainActor.run {
                error = "No note to delete"
                isLoading = false
            }
            return
        }
        
        do {
            try await notesViewModel.deleteNote(id: note.id)
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        } catch let deleteError {  // ✅ Renamed to avoid collision
            await MainActor.run {
                error = "Failed to delete note: \(deleteError.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func toggleHeader() {
        guard selectedRange.length > 0 else { return }
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        var isCurrentlyHeader = false
        if let font = attributedText
            .attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
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
        if let font = attributedText
            .attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
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
        if let font = attributedText
            .attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
        }
        let newFont = isCurrentlyItalic
            ? UIFont.systemFont(ofSize: 17)
            : UIFont.italicSystemFont(ofSize: 17)
        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }
}
