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

    init(viewModel: NotesViewModel, userId: String, note: Note? = nil) {
        print("Initializing AddNoteView")
        print("Note: \(String(describing: note))")
        self.viewModel = viewModel
        self.userId = userId
        self.isEditing = note != nil
        print("hello")
        // Initialize attributedText based on whether we're editing or creating
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
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        toggleBold()
                    }) {
                        Image(systemName: "bold")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        toggleItalic()
                    }) {
                        Image(systemName: "italic")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray6))
                
                // Text editor
                FormattedTextView(attributedText: $attributedText, selectedRange: $selectedRange)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        // Convert attributed text to plain text for storage
                        let plainText = attributedText.string
                        viewModel.addNote(content: plainText, userId: userId)
                        dismiss()
                    }
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
