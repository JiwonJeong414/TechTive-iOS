//
//  NotesFeedSection.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct NotesFeedSection: View {
    @ObservedObject var viewModel: NotesViewModel
    let isLimitedAccess: Bool
    
    @State private var selectedNote: Note? = nil
    @State private var showingEditor = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isLimitedAccess {
                // Limited preview version
                VStack(spacing: 16) {
                    NoteCard(note: Note(content: "Preview Note", userId: "preview"), index: 1)
                        .opacity(0.7)
                    
                    Text("Sign in to see more notes and create your own")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                // Show full notes feed with alternating colors
                ZStack(alignment: .top){
                    ForEach(Array(viewModel.notes.enumerated()), id: \.element.id) { index, note in
                        NoteCard(note: note, index: index)
                            .padding(.top, CGFloat(index) * 100) // Use padding instead of offset
                            .zIndex(Double(index)) // Higher index cards render on top
                            .onTapGesture {
                                selectedNote = note
                                showingEditor = true
                            }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
        .sheet(item: $selectedNote) { note in
            AddNoteView(
                viewModel: viewModel,
                userId: note.userId,
                note: note
            )
        }
    }
}

#Preview {
    MainView(isLimitedAccess: false)
}
