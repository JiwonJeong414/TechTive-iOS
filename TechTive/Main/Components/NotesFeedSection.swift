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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Notes")
                .font(.title2)
                .bold()
            
            if isLimitedAccess {
                // Show limited preview for non-authenticated users
                VStack(spacing: 16) {
                    NoteCard(note: Note(content: "Preview Note", userId: "preview"))
                        .opacity(0.7)
                    
                    Text("Sign in to see more notes and create your own")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                // Show full notes feed for authenticated users
                ForEach(viewModel.notes) { note in
                    NoteCard(note: note)
                }
            }
        }
    }
}

#Preview {
    NotesFeedSection(viewModel: NotesViewModel(), isLimitedAccess: false)
}
