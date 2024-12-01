//
//  AddNoteView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var attributedText: NSAttributedString
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @ObservedObject var viewModel: NotesViewModel
    let userId: String
    let isEditing: Bool
    private let originalNote: Note?

    init(viewModel: NotesViewModel, userId: String, note: Note? = nil) {
        print("Initializing AddNoteView")
        print("Note: \(String(describing: note))")
        self.viewModel = viewModel
        self.userId = userId
        self.isEditing = note != nil
        self.originalNote = note // Store the original note

        if let note = note {
            _attributedText = State(initialValue: note.toAttributedString())
        } else {
            _attributedText = State(initialValue: NSAttributedString(string: ""))
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Formatting toolbar
                HStack(spacing: 16) {
                    Button(action: {
                        toggleHeader()
                    }) {
                        Image(systemName: "textformat.size.larger")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    
                    Button(action: {
                        toggleBold()
                    }) {
                        Image(systemName: "bold")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    
                    Button(action: {
                        toggleItalic()
                    }) {
                        Image(systemName: "italic")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Divider()
                    .background(Color.orange)
                
                // Text editor
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
                        if isEditing, let original = originalNote {
                            let updatedNote = Note(
                                attributedString: attributedText,
                                userId: userId,
                                id: original.id  // Pass the original ID for updates
                            )
                            viewModel.updateNote(updatedNote)
                        } else {
                            viewModel.addNote(
                                attributedString: attributedText,
                                userId: userId
                            )
                        }
                        dismiss()
                    }
                    .foregroundColor(Color(UIColor.color.orange))
                }
            }
        }
    }
    
    private func toggleHeader() {
        guard selectedRange.length > 0 else { return }
        
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        
        // Check if current style is header
        var isCurrentlyHeader = false
        if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyHeader = font.pointSize >= 24
        }
        
        // Toggle header style
        let newFont = isCurrentlyHeader
            ? UIFont.systemFont(ofSize: 17)
            : UIFont.systemFont(ofSize: 24, weight: .bold)
        
        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }
    
    private func toggleBold() {
        guard selectedRange.length > 0 else { return }
        
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        
        // Check if current style is bold
        var isCurrentlyBold = false
        if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
        }
        
        // Toggle bold style
        let newFont = isCurrentlyBold
            ? UIFont.systemFont(ofSize: 17)
            : UIFont.boldSystemFont(ofSize: 17)
        
        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }
    
    private func toggleItalic() {
        guard selectedRange.length > 0 else { return }
        
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        
        // Check if current style is italic
        var isCurrentlyItalic = false
        if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
        }
        
        // Toggle italic style
        let newFont = isCurrentlyItalic
            ? UIFont.systemFont(ofSize: 17)
            : UIFont.italicSystemFont(ofSize: 17)
        
        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }
}

#Preview {
    AddNoteView(viewModel: NotesViewModel(), userId: "123")
}
