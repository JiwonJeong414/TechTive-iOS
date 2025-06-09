import SwiftUI

/// A custom shape that creates a trapezoid with a wider top base and narrower bottom base
struct TrapezoidShape: Shape {
    // MARK: - Constants

    private let inset: CGFloat = 25
    private let height: CGFloat = -15
    private let baseWidth: CGFloat = 30

    // MARK: - Shape Implementation

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Top base (wider)
        path.move(to: CGPoint(x: rect.midX - self.baseWidth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + self.baseWidth, y: rect.minY))

        // Right diagonal to bottom base
        path.addLine(to: CGPoint(x: rect.midX + self.inset, y: rect.minY + self.height))

        // Bottom base (narrower than top but wider than before)
        path.addLine(to: CGPoint(x: rect.midX - self.inset, y: rect.minY + self.height))

        path.closeSubpath()

        return path
    }
}
