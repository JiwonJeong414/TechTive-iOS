import SwiftUI

struct CustomGraphPopup: View {
    let note: Note
    let onDismiss: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Transparent background to catch taps outside the card
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { self.onDismiss() }

                VStack(spacing: 0) {
                    GraphView(note: self.note)
                        .frame(width: 280, height: 280)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                    TrianglePointer()
                        .frame(width: 36, height: 24)
                        .foregroundColor(Color(Constants.Colors.backgroundColor))
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(Constants.Colors.backgroundColor))
                        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4))
                .padding(.horizontal, 32)
                .frame(maxWidth: 340)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
