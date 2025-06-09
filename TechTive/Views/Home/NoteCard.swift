import SwiftUI

/// A card view that displays a single note with its content, date, and emotion analysis
struct NoteCard: View {
    // MARK: - Properties

    let note: Note
    let index: Int
    @ObservedObject var noteViewModel: NotesViewModel
    @StateObject private var viewModel: NoteCardViewModel

    // MARK: - Init

    init(note: Note, index: Int, noteViewModel: NotesViewModel) {
        self.note = note
        self.index = index
        self.noteViewModel = noteViewModel
        _viewModel = StateObject(wrappedValue: NoteCardViewModel(note: note, index: index))
    }

    // MARK: - UI

    var body: some View {
        GeometryReader { mainGeo in
            HStack(spacing: 0) {
                self.trapezoidView

                VStack(alignment: .leading, spacing: 4) {
                    self.noteContent
                    self.noteFooter
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 105)
            .background(self.viewModel.backgroundForIndex())
            .offset(x: self.viewModel.offset)
            .onAppear {
                self.viewModel.appear()
            }
            .onChange(of: self.noteViewModel.notes.count) { _, _ in
                self.viewModel.updateTrapezoidPosition(mainGeo.frame(in: .global).minY)
            }
            .popover(isPresented: self.$viewModel.showingGraph) {
                GraphView(note: self.note)
                    .frame(width: 300, height: 300)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }

    private var noteContent: some View {
        HStack {
            Text(self.note.content)
                .font(.custom("CourierPrime-Regular", fixedSize: 18))
                .foregroundColor(Color(Constants.Colors.orange))
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(Constants.Colors.orange))
        }
    }

    private var noteFooter: some View {
        HStack {
            Text(self.note.timestamp.shortDateString)
                .font(.custom("Poppins-Regular", fixedSize: 14))
                .foregroundColor(Color(Constants.Colors.darkPurple))

            Spacer()

            self.emotionButton
        }
    }

    private var emotionButton: some View {
        Button(action: {
            self.viewModel.showingGraph = true
        }) {
            HStack(spacing: 4) {
                Text(self.viewModel.isEmotionLoading ? "Loading" : self.note.dominantEmotion.emotion)
                    .font(.custom("Poppins-Regular", fixedSize: 12))
                    .foregroundColor(Color(Constants.Colors.darkPurple))
                if self.viewModel.isEmotionLoading {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(Color(Constants.Colors.darkPurple))
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(Constants.Colors.darkPurple).opacity(0.1)))
        }
    }

    private var trapezoidView: some View {
        TrapezoidShape()
            .fill(self.viewModel.backgroundForIndex())
            .frame(width: 40, height: 10)
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            self.viewModel.updateTrapezoidPosition(geometry.frame(in: .global).minY)
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                            self.viewModel.updateTrapezoidPosition(newValue)
                        }
                })
            .offset(x: self.viewModel.calculateOffset(), y: -47)
            .id("trapezoid-\(self.note.id)")
    }
}
