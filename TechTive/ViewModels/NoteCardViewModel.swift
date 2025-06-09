import SwiftUI

@MainActor class NoteCardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var trapezoidPosition: CGFloat = 0
    @Published var offset: CGFloat = 0
    @Published var showingGraph = false
    @Published var hasAppeared = false

    // MARK: - Properties

    private let note: Note
    private let index: Int
    private let animationSpeed: CGFloat = 2.0
    private let startingOffset: CGFloat = 0

    // MARK: - Init

    init(note: Note, index: Int) {
        self.note = note
        self.index = index
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
        return self.note.angerValue == 0 &&
            self.note.disgustValue == 0 &&
            self.note.fearValue == 0 &&
            self.note.joyValue == 0 &&
            self.note.neutralValue == 0 &&
            self.note.sadnessValue == 0 &&
            self.note.surpriseValue == 0
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
