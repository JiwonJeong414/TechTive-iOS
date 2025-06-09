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
            let valueScale = self.values.isEmpty ? 1.0 : self.values[i]
            let x = center.x + radius * cos(angle) * valueScale
            let y = center.y + radius * sin(angle) * valueScale

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
