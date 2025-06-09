import SwiftUI

/// Generates a Notes Feed Section based on the notes in the NotesViewModel
struct NotesFeedSection: View {
    // MARK: - Properties

    @EnvironmentObject var notesViewModel: NotesViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: ViewModel

    // MARK: - Init

    init() {
        _viewModel = StateObject(wrappedValue: ViewModel(notesViewModel: NotesViewModel()))
    }

    // MARK: - UI

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            self.notesStack
            self.bottomRectangle
        }
        .padding(.vertical, 10)
        .sheet(item: self.$viewModel.selectedNote) { note in
            AddNotesView(note: note)
                .environmentObject(self.notesViewModel)
                .environmentObject(self.authViewModel)
        }
        .onChange(of: self.viewModel.refreshTrigger) {
            Task {
                await self.viewModel.refreshNotes()
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
                        self.viewModel.selectNote(note)
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomRectangle: some View {
        Rectangle()
            .fill(self.viewModel.bottomColor(for: self.notesViewModel.notes.count))
            .frame(height: 100)
            .offset(y: 95)
    }
}
