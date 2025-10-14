//
//  NoteCard.swift
//  TechTive
//

import SwiftUI

/// A card view that displays a single note with its content, date, and emotion analysis
struct NoteCard: View {
    // MARK: - Properties

    let note: Note
    let index: Int
    @ObservedObject var noteViewModel: NotesViewModel
    @StateObject private var viewModel: ViewModel

    // MARK: - Init

    init(note: Note, index: Int, noteViewModel: NotesViewModel) {
        self.note = note
        self.index = index
        self.noteViewModel = noteViewModel
        _viewModel = StateObject(wrappedValue: ViewModel(note: note, index: index))
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
                // Update the index when notes change
                if let newIndex = self.noteViewModel.notes.firstIndex(where: { $0.id == self.note.id }) {
                    self.viewModel.updateIndex(newIndex)
                }
                // Force position update
                self.viewModel.forceUpdatePosition()
            }
            .sheet(isPresented: self.$viewModel.showingGraph) {
                CustomGraphSheet(note: self.note, isPresented: self.$viewModel.showingGraph)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var noteContent: some View {
        HStack {
            Text(self.note.content)
                .font(Constants.Fonts.courierPrime18)
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
                .font(Constants.Fonts.poppinsRegular14)
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
                    .font(Constants.Fonts.poppinsRegular12)
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

// MARK: - ViewModel

extension NoteCard {
    @MainActor
    class ViewModel: ObservableObject {
        // MARK: - Published Properties

        @Published var trapezoidPosition: CGFloat = 0
        @Published var offset: CGFloat = 0
        @Published var showingGraph = false
        @Published var hasAppeared = false

        // MARK: - Properties

        private let note: Note
        @Published var index: Int
        private let animationSpeed: CGFloat = 2.0
        private let startingOffset: CGFloat = 0

        // MARK: - Init

        init(note: Note, index: Int) {
            self.note = note
            self.index = index
        }

        // MARK: - Update Methods

        func updateIndex(_ newIndex: Int) {
            self.index = newIndex
        }

        func forceUpdatePosition() {
            // Force a position update when notes change
            withAnimation(.easeInOut(duration: 0.3)) {
                self.objectWillChange.send()
            }
        }

        // MARK: - Methods

        func calculateOffset() -> CGFloat {
            let baseOffset = CGFloat(index * 50 + 11)
            let screenHeight = UIScreen.main.bounds.height
            let adjustedPosition = self.trapezoidPosition * self.animationSpeed
            let scrollProgress = min(max(adjustedPosition / screenHeight, 0), 1)
            let maxMovement: CGFloat = 400
            return (baseOffset + self.startingOffset) - ((1 - scrollProgress) * maxMovement)
        }

        func backgroundForIndex() -> Color {
            switch self.index % 3 {
                case 0: return Color(Constants.Colors.purple)
                case 1: return Color(Constants.Colors.lightOrange)
                case 2: return Color(Constants.Colors.lightYellow)
                default: return Color(Constants.Colors.lightYellow)
            }
        }

        var isEmotionLoading: Bool {
            // Check if emotional analysis is still loading
            // If all values are 0 except neutral (which defaults to 1.0), then it's still loading
            let hasEmotionData = self.note.angerValue > 0 ||
                self.note.disgustValue > 0 ||
                self.note.fearValue > 0 ||
                self.note.joyValue > 0 ||
                self.note.sadnessValue > 0 ||
                self.note.surpriseValue > 0

            // If we only have neutral at 1.0 and everything else is 0, it's likely still loading
            let isDefaultState = !hasEmotionData && self.note.neutralValue == 1.0

            // Also check if the note was just created (within last 30 seconds) and still has default values
            let isRecentlyCreated = Date().timeIntervalSince(self.note.timestamp) < 30

            return isDefaultState && isRecentlyCreated
        }

        func updateTrapezoidPosition(_ position: CGFloat) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.trapezoidPosition = position
            }
        }

        func appear() {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.hasAppeared = true
            }
        }
    }
}
