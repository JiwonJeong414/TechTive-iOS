import SwiftUI

struct NotesFeedSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject var viewModel: NotesViewModel // Change this line
    @State private var selectedNote: Note? = nil
    @State private var showingEditor = false
    @State private var timer: Timer? = nil
    @State private var refreshTrigger = false

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
            ZStack(alignment: .top) {
                ForEach(Array(self.viewModel.notes.enumerated()), id: \.element.id) { index, note in
                    NoteCard(note: note, index: index, noteViewModel: self.viewModel)
                        .padding(.top, CGFloat(index) * 100)
                        .zIndex(Double(index))
                        .onTapGesture {
                            self.selectedNote = note
                            self.showingEditor = true
                        }
                }
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(self.bottomColor(self.viewModel.notes.count))
                .frame(height: 100)
                .offset(y: 95)
        }
        .padding(.vertical, 10)
        .sheet(item: self.$selectedNote) { note in
            AddNoteView(viewModel: self.viewModel, note: note)
                .environmentObject(self.authViewModel)
        }
        .onChange(of: self.refreshTrigger) { // New iOS 17 syntax
            Task {
                try? await Task.sleep(for: .seconds(2))
                await self.viewModel.fetchNotes()
            }
        }
        .onAppear {
            Task {
                await self.viewModel.fetchNotes()
            }
        }
    }
}
