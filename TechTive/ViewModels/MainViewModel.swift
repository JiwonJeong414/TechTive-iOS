import SwiftUI

@MainActor class MainViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var showHeader = false
    @Published var showQuote = false
    @Published var showWeekly = false
    @Published var showNotes = false
    @Published var showAddButton = false
    @Published var showAddNote = false

    // MARK: - Properties

    private let animationDuration = 0.6
    private let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7)

    // MARK: - Methods

    func startAnimations() {
        withAnimation(.easeIn(duration: self.animationDuration)) {
            self.showHeader = true
        }
        withAnimation(.easeIn(duration: self.animationDuration).delay(0.3)) {
            self.showQuote = true
        }
        withAnimation(.easeIn(duration: self.animationDuration).delay(0.6)) {
            self.showWeekly = true
        }
        withAnimation(.easeIn(duration: self.animationDuration).delay(0.9)) {
            self.showNotes = true
        }
        withAnimation(self.springAnimation.delay(1.2)) {
            self.showAddButton = true
        }
    }

    func toggleAddNote() {
        self.showAddNote.toggle()
    }
}
