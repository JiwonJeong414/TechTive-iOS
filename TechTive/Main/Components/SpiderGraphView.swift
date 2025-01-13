//
//  SpiderGraphView.swift
//  TechTive
//
//  Created by Keya Aggarwal on 06/12/24.
//


import SwiftUI

struct SpiderGraphView: View {
    // Values for the 7 variables (0 to 1)
    let values: [Double]
    let labels: [String]
    
    private let accentColor = Color(UIColor.color.orange)
    private let Background = Color(UIColor.color.lightYellow)
    private let sides = 7
    
    // Add a computed property to check if all values are 0
    private var isLoading: Bool {
        values.allSatisfy { $0 == 0 }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) / 2 * 0.8
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            ZStack {
                Background.ignoresSafeArea()
                
                if isLoading {
                    // Loading placeholder
                    VStack {
                        Text("Loading...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        ProgressView()
                    }
                } else {
                    ZStack {
                        spiderGrid(size: size, center: center)
                        dataPolygon(size: size, center: center)
                        axisLabels(size: size, center: center)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(25)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    // Helper to draw the grid
    @ViewBuilder
    private func spiderGrid(size: CGFloat, center: CGPoint) -> some View {
        ForEach(1...5, id: \.self) { level in
            Polygon(sides: sides, scale: Double(level) / 5.0)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .frame(width: size * 2, height: size * 2)
                .position(center)
        }
    }

    // Helper to draw the data polygon
    @ViewBuilder
    private func dataPolygon(size: CGFloat, center: CGPoint) -> some View {
        if values.count == sides {
            Polygon(sides: sides, values: values)
                .fill(accentColor.opacity(0.3))
                .overlay(
                    Polygon(sides: sides, values: values)
                        .stroke(accentColor, lineWidth: 2)
                )
                .frame(width: size * 2, height: size * 2)
                .position(center)
        }
    }

    // Helper to add axis labels
    @ViewBuilder
    private func axisLabels(size: CGFloat, center: CGPoint) -> some View {
        ForEach(0..<sides, id: \.self) { i in
            // Calculate angle for the current side
            let angle = calculateAngle(for: i, totalSides: sides)

            // Calculate position for the label
            let position = calculatePosition(center: center, size: size, angle: angle)

            // Display label
            Text(labels[i])
                .font(.caption)
                .foregroundColor(.black)
                .position(x: position.x, y: position.y)
        }
    }

    // Helper function to calculate the angle
    private func calculateAngle(for index: Int, totalSides: Int) -> Double {
        return Double(index) * (2 * .pi / Double(totalSides)) - .pi / 2
    }

    // Helper function to calculate position based on center, size, and angle
    private func calculatePosition(center: CGPoint, size: CGFloat, angle: Double) -> CGPoint {
        let offset = size + 20
        let x = center.x + offset * cos(angle)
        let y = center.y + offset * sin(angle)
        return CGPoint(x: x, y: y)
    }


}

struct Polygon: Shape {
    var sides: Int
    var scale: Double = 1.0
    var values: [Double] = []
    
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.size.width, rect.size.height) / 2 * scale
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        
        for i in 0..<sides {
            let angle = Double(i) * (2 * .pi / Double(sides)) - .pi / 2
            let valueScale = values.isEmpty ? 1.0 : values[i]
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
struct GraphView: View {
    private let cardBackground = Color(UIColor.color.backgroundColor)
    private let accentColor = Color(UIColor.color.orange)
    let note: Note
    
    // Add a computed property to check if all values are 0
    private var isLoading: Bool {
        let emotionValues = [
            note.angerValue,
            note.disgustValue,
            note.fearValue,
            note.joyValue,
            note.neutralValue,
            note.sadnessValue,
            note.surpriseValue
        ]
        return emotionValues.allSatisfy { $0 == 0 }
    }

    var body: some View {
        let emotionValues = [
            note.angerValue,
            note.disgustValue,
            note.fearValue,
            note.joyValue,
            note.neutralValue,
            note.sadnessValue,
            note.surpriseValue
        ]
        
        let emotionLabels = ["Anger", "Disgust", "Fear", "Joy", "Neutral", "Sad", "Surprise"]
        
        ZStack {
            cardBackground.ignoresSafeArea()
            VStack(spacing: 24) {
                SpiderGraphView(
                    values: emotionValues,
                    labels: emotionLabels
                )
                .frame(width: 300, height: 300)
                .padding()
                .background(cardBackground)
            }
        }
    }
}

