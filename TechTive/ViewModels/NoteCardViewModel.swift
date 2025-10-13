import SwiftUI

@MainActor class NoteCardViewModel: ObservableObject {
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
