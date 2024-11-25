//
//  AddNoteView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

// MARK: - Add Note View
struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var noteText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $noteText)
                    .padding()
                    .frame(height: 200)
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
                        // Add save logic here
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddNoteView()
}
