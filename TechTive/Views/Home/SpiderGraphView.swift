import SwiftUI

/// A view that displays a spider/radar graph with configurable values and labels
struct SpiderGraphView: View {
    // MARK: - Properties

    let values: [Double]
    let labels: [String]

    // MARK: - Constants

    private let accentColor = Color(Constants.Colors.orange)
    private let Background = Color(Constants.Colors.lightYellow)
    private let sides = 7

    // MARK: - Computed Properties

    private var isLoading: Bool {
        self.values.allSatisfy { $0 == 0 }
    }

    // MARK: - UI

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) / 2 * 0.8
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                self.Background.ignoresSafeArea()

                if self.isLoading {
                    self.loadingView
                } else {
                    self.graphContent(size: size, center: center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(25)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - UI Components

    private var loadingView: some View {
        VStack {
            Text("Loading...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            ProgressView()
        }
    }

    private func graphContent(size: CGFloat, center: CGPoint) -> some View {
        ZStack {
            self.spiderGrid(size: size, center: center)
            self.dataPolygon(size: size, center: center)
            self.axisLabels(size: size, center: center)
        }
    }

    // MARK: - Graph Components

    @ViewBuilder private func spiderGrid(size: CGFloat, center: CGPoint) -> some View {
        ForEach(1 ... 5, id: \.self) { level in
            Polygon(sides: self.sides, scale: Double(level) / 5.0)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .frame(width: size * 2, height: size * 2)
                .position(center)
        }
    }

    @ViewBuilder private func dataPolygon(size: CGFloat, center: CGPoint) -> some View {
        if self.values.count == self.sides {
            Polygon(sides: self.sides, values: self.values)
                .fill(self.accentColor.opacity(0.3))
                .overlay(
                    Polygon(sides: self.sides, values: self.values)
                        .stroke(self.accentColor, lineWidth: 2))
                .frame(width: size * 2, height: size * 2)
                .position(center)
        }
    }

    @ViewBuilder private func axisLabels(size: CGFloat, center: CGPoint) -> some View {
        ForEach(0 ..< self.sides, id: \.self) { i in
            let angle = self.calculateAngle(for: i, totalSides: self.sides)
            let position = self.calculatePosition(center: center, size: size, angle: angle)

            Text(self.labels[i])
                .font(.caption)
                .foregroundColor(.black)
                .position(x: position.x, y: position.y)
        }
    }

    // MARK: - Helper Methods

    private func calculateAngle(for index: Int, totalSides: Int) -> Double {
        return Double(index) * (2 * .pi / Double(totalSides)) - .pi / 2
    }

    private func calculatePosition(center: CGPoint, size: CGFloat, angle: Double) -> CGPoint {
        let offset = size + 20
        let x = center.x + offset * cos(angle)
        let y = center.y + offset * sin(angle)
        return CGPoint(x: x, y: y)
    }
}
