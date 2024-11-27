//
//  AddNoteView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var noteText = ""
    @ObservedObject var viewModel: NotesViewModel
    let userId: String
    
    var body: some View {
        NavigationView {
            FormattedTextView(text: $noteText)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()
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
                            viewModel.addNote(content: noteText, userId: userId)
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    AddNoteView(viewModel: NotesViewModel(), userId: "123")
}
