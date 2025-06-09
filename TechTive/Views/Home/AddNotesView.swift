import Alamofire
import SwiftUI

/// View for adding or editing a note.
struct AddNotesView: View {
    // MARK: - Properties

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @StateObject private var viewModel: ViewModel

    // Passing down the specific note to edit

    init(note: Note? = nil) {
        _viewModel = StateObject(wrappedValue: ViewModel(note: note))
    }

    // MARK: - UI

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                self.formattingToolbar
                Divider().background(Color.orange)
                self.errorSection
                self.textEditorSection
            }
            .background(Color(Constants.Colors.lightYellow).opacity(0.3))
            .navigationTitle(self.viewModel.isEditing ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        self.dismiss()
                    }
                    .foregroundColor(Color(Constants.Colors.orange))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(self.viewModel.isEditing ? "Save" : "Post") {
                        self.viewModel.isLoading = true
                        self.viewModel.error = nil
                        Task {
                            await self.viewModel.postNote(notesViewModel: self.notesViewModel) {
                                self.dismiss()
                            }
                            self.viewModel.isLoading = false
                        }
                    }
                    .foregroundColor(Color(Constants.Colors.orange))
                    .disabled(self.viewModel.isLoading || self.viewModel.attributedText.string.isEmpty)
                }
            }
            .overlay(self.loadingOverlay)
        }
    }

    // MARK: - Components

    private var formattingToolbar: some View {
        HStack(spacing: 16) {
            Button(action: { self.viewModel.toggleHeader() }) {
                Image(systemName: "textformat.size.larger")
                    .foregroundColor(Color(Constants.Colors.orange))
            }
            Button(action: { self.viewModel.toggleBold() }) {
                Image(systemName: "bold")
                    .foregroundColor(Color(Constants.Colors.orange))
            }
            Button(action: { self.viewModel.toggleItalic() }) {
                Image(systemName: "italic")
                    .foregroundColor(Color(Constants.Colors.orange))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var errorSection: some View {
        Group {
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    private var textEditorSection: some View {
        FormattedTextView(attributedText: self.$viewModel.attributedText, selectedRange: self.$viewModel.selectedRange)
            .background(Color(Constants.Colors.lightYellow))
            .cornerRadius(12)
            .padding()
    }

    private var loadingOverlay: some View {
        Group {
            if self.viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4))
            }
        }
    }
}
