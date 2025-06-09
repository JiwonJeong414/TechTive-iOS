import SwiftUI

struct StickyNoteBackground: View {
    let stickyColor: Color
    let foldColor: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(self.stickyColor)
    }
}
