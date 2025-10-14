//
//  NotesFeedSection.swift
//  TechTive
//

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
            if self.notesViewModel.notes.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "note.text")
                        .font(.system(size: 48))
                        .foregroundColor(Color(Constants.Colors.gray).opacity(0.5))

                    Text("No notes yet")
                        .font(Constants.Fonts.poppinsMedium16)
                        .foregroundColor(Color(Constants.Colors.gray))

                    Text("Start writing your first note!")
                        .font(Constants.Fonts.poppinsRegular14)
                        .foregroundColor(Color(Constants.Colors.gray).opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                ForEach(Array(self.notesViewModel.notes.enumerated()), id: \.element.id) { index, note in
                    NoteCard(note: note, index: index, noteViewModel: self.notesViewModel)
                        .padding(.top, CGFloat(index) * 100)
                        .zIndex(Double(index))
                        .onTapGesture {
                            self.viewModel.selectNote(note)
                        }
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

// MARK: - ViewModel

extension NotesFeedSection {
    @MainActor class ViewModel: ObservableObject {
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
}
