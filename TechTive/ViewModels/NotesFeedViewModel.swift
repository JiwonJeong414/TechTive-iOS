import SwiftUI

@MainActor class NotesFeedViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var selectedNote: Note?
    @Published var showingEditor = false
    @Published var refreshTrigger = false

    // MARK: - Properties

    private let notesViewModel: NotesViewModel

    // MARK: - Init

    init(notesViewModel: NotesViewModel) {
        self.notesViewModel = notesViewModel
    }

    // MARK: - Methods

    func bottomColor(for count: Int) -> Color {
        guard count > 0 else { return .clear }
        let lastIndex = count - 1
        switch lastIndex % 3 {
            case 0: return Color(Constants.Colors.purple)
            case 1: return Color(Constants.Colors.lightOrange)
            case 2: return Color(Constants.Colors.lightYellow)
            default: return .clear
        }
    }

    func selectNote(_ note: Note) {
        self.selectedNote = note
        self.showingEditor = true
    }

    func refreshNotes() async {
        try? await Task.sleep(for: .seconds(2))
        await self.notesViewModel.fetchNotes()
    }
}
