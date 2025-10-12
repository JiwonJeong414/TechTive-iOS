import SwiftUI

/// A custom shape that creates a polygon with configurable sides and values
struct Polygon: Shape {
    // MARK: - Properties

    var sides: Int
    var scale = 1.0
    var values: [Double] = []

    // MARK: - Shape Implementation

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.size.width, rect.size.height) / 2 * self.scale
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()

        for i in 0 ..< self.sides {
            let angle = Double(i) * (2 * .pi / Double(self.sides)) - .pi / 2
            let rawValue = self.values.isEmpty ? 1.0 : self.values[i]
            // Apply minimum threshold to ensure visible shape even with small values
            let valueScale = max(rawValue, 0.1) // Minimum 10% of radius for visibility

            // Ensure we don't pass NaN values to CoreGraphics
            let x = center.x + radius * cos(angle) * valueScale
            let y = center.y + radius * sin(angle) * valueScale

            // Validate coordinates to prevent NaN
            let validX = x.isFinite ? x : center.x
            let validY = y.isFinite ? y : center.y

            if i == 0 {
                path.move(to: CGPoint(x: validX, y: validY))
            } else {
                path.addLine(to: CGPoint(x: validX, y: validY))
            }
        }
        path.closeSubpath()
        return path
    }
}
