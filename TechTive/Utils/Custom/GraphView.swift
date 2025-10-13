import SwiftUI

/// A view that displays a spider graph visualization of emotion values for a note
struct GraphView: View {
    // MARK: - Properties

    private let cardBackground = Color(Constants.Colors.backgroundColor)
    private let accentColor = Color(Constants.Colors.orange)
    let note: Note

    // MARK: - Computed Properties

    private var isLoading: Bool {
        let emotionValues = [
            note.angerValue,
            self.note.disgustValue,
            self.note.fearValue,
            self.note.joyValue,
            self.note.neutralValue,
            self.note.sadnessValue,
            self.note.surpriseValue
        ]
        return emotionValues.allSatisfy { $0 == 0 }
    }

    private var emotionValues: [Double] {
        [
            self.note.angerValue,
            self.note.disgustValue,
            self.note.fearValue,
            self.note.joyValue,
            self.note.neutralValue,
            self.note.sadnessValue,
            self.note.surpriseValue
        ]
    }

    private var emotionLabels: [String] {
        ["Anger", "Disgust", "Fear", "Joy", "Neutral", "Sad", "Surprise"]
    }

    // MARK: - UI

    var body: some View {
        ZStack {
            self.cardBackground.ignoresSafeArea()
            VStack(spacing: 24) {
                SpiderGraphView(
                    values: self.emotionValues,
                    labels: self.emotionLabels)
                    .frame(width: 300, height: 300)
            }
        }
    }
}
