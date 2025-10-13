import SwiftUI

/// A modal view that displays the emotion analysis graph for a note
struct EmotionsGraphModal: View {
    // MARK: - Properties

    @Environment(\.dismiss) var dismiss
    let note: Note

    // MARK: - UI

    var body: some View {
        NavigationView {
            GraphView(note: self.note)
                .navigationBarItems(
                    trailing: Button("Done") {
                        self.dismiss()
                    })
        }
    }
}
