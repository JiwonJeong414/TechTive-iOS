//
//  NotesFeedSection.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct NotesFeedSection: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var selectedNote: Note? = nil
    @State private var showingEditor = false
    @State private var timer: Timer? = nil

    
    private func bottomColor(_ count: Int) -> Color {
        guard count > 0 else { return .clear }
        let lastIndex = count - 1
        switch lastIndex % 3 {
            case 0: return Color(UIColor.color.purple)
            case 1: return Color(UIColor.color.lightOrange)
            case 2: return Color(UIColor.color.lightYellow)
            default: return .clear
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Show full notes feed with alternating colors
            ZStack(alignment: .top){
                ForEach(Array(viewModel.notes.enumerated()), id: \.element.id) { index, note in
                    NoteCard(note: note, index: index, noteViewModel: viewModel)
                        .padding(.top, CGFloat(index) * 100) // Use padding instead of offset
                        .zIndex(Double(index)) // Higher index cards render on top
                        .onTapGesture {
                            selectedNote = note
                            showingEditor = true
                        }
                }
            }
            .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(bottomColor(viewModel.notes.count))
                .frame(height: 100)
                .offset(y:  95)
        }
        .padding(.vertical, 10)
        .sheet(item: $selectedNote) { note in
            AddNoteView(
                viewModel: viewModel,
                note: note
            )
            .environmentObject(AuthViewModel())
        }
        .onAppear {
            Task {
                await viewModel.fetchNotes()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())

}
