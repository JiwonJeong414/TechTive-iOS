import SwiftUI

/// Generates a Notes Feed Section based on the notes in the NotesViewModel
struct NotesFeedSection: View {
    // MARK: - Properties

    @EnvironmentObject var notesViewModel: NotesViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedNote: Note? = nil
    @State private var showingEditor = false
    @State private var timer: Timer? = nil
    @State private var refreshTrigger = false

    // MARK: - Helper Methods

    private func bottomColor(_ count: Int) -> Color {
        guard count > 0 else { return .clear }
        let lastIndex = count - 1
        switch lastIndex % 3 {
            case 0: return Color(Constants.Colors.purple)
            case 1: return Color(Constants.Colors.lightOrange)
            case 2: return Color(Constants.Colors.lightYellow)
            default: return .clear
        }
    }

    // MARK: - UI

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            self.notesStack
            self.bottomRectangle
        }
        .padding(.vertical, 10)
        .sheet(item: self.$selectedNote) { note in
            AddNotesView(note: note)
                .environmentObject(self.notesViewModel)
                .environmentObject(self.authViewModel)
        }
        .onChange(of: self.refreshTrigger) {
            Task {
                try? await Task.sleep(for: .seconds(2))
                await self.notesViewModel.fetchNotes()
            }
        }
        .onAppear {
            Task {
                await self.notesViewModel.fetchNotes()
            }
        }
    }

    private var notesStack: some View {
        ZStack(alignment: .top) {
            ForEach(Array(self.notesViewModel.notes.enumerated()), id: \.element.id) { index, note in
                NoteCard(note: note, index: index, noteViewModel: self.notesViewModel)
                    .padding(.top, CGFloat(index) * 100)
                    .zIndex(Double(index))
                    .onTapGesture {
                        self.selectedNote = note
                        self.showingEditor = true
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomRectangle: some View {
        Rectangle()
            .fill(self.bottomColor(self.notesViewModel.notes.count))
            .frame(height: 100)
            .offset(y: 95)
    }
}
