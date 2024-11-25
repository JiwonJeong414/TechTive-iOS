//
//  NotesFeedSection.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct NotesFeedSection: View {
    let isLimitedAccess: Bool
    let notes = ["Note 1", "Note 2", "Note 3"] // Replace with data model
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Notes")
                .font(.title2)
                .bold()
            
            if isLimitedAccess {
                // Show limited preview for non-authenticated users
                VStack(spacing: 16) {
                    NoteCard(note: "Preview Note")
                        .opacity(0.7)
                    
                    Text("Sign in to see more notes and create your own")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                // Show full notes feed for authenticated users
                ForEach(notes, id: \.self) { note in
                    NoteCard(note: note)
                }
            }
        }
    }
}

#Preview {
    NotesFeedSection(isLimitedAccess: false)
}
