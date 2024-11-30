//
//  NoteCard.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI


struct NoteCard: View {
    let note: Note
    let index: Int
    @State private var trapezoidPosition: CGFloat = 0
    
    // Add animation speed control
    private let animationSpeed: CGFloat = 2.0 // Increase this value for faster animation
    // Add starting position offset
    private let startingOffset: CGFloat = 0 // Adjust this value to change starting position
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        return formatter
    }()
    
    var body: some View {
        GeometryReader { mainGeo in
            HStack(spacing: 0) {
                // Left tab with geometry reader for position tracking
                TrapezoidShape()
                    .fill(backgroundForIndex(index))
                    .frame(width: 40, height: 10)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onChange(of: geometry.frame(in: .global).minY) { oldValue, newValue in
                                    trapezoidPosition = newValue
                                }
                        }
                    )
                    .offset(x: calculateOffset(), y: -47)
                
                // Main content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(note.content)
                            .font(.custom("CourierPrime-Regular", size: 18))
                            .foregroundColor(Color(UIColor.color.orange))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    
                    Text(dateFormatter.string(from: note.timestamp))
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color(UIColor.color.darkPurple))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 105)
            .background(backgroundForIndex(index))
        }
    } 
    
    private func calculateOffset() -> CGFloat {
        let baseOffset = CGFloat(index * 50 + 11)
        let screenHeight = UIScreen.main.bounds.height
        
        // Adjust scroll progress calculation with animation speed
        let adjustedPosition = trapezoidPosition * animationSpeed
        let scrollProgress = min(max(adjustedPosition / screenHeight, 0), 1)
        
        // Add starting offset to base position
        let maxMovement: CGFloat = 400
        return (baseOffset + startingOffset) - ((1 - scrollProgress) * maxMovement)
    }
    
    private func backgroundForIndex(_ index: Int) -> Color {
        switch index % 3 {
            case 0: return Color(UIColor.color.purple)
            case 1: return Color(UIColor.color.lightOrange)
            case 2: return Color(UIColor.color.lightYellow)
            default: return Color(UIColor.color.lightYellow)
        }
    }
}

struct TrapezoidShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let inset: CGFloat = 25
        let height: CGFloat = -15
        let baseWidth: CGFloat = 30
        
        // Top base (wider)
        path.move(to: CGPoint(x: rect.midX - baseWidth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + baseWidth, y: rect.minY))
        
        // Right diagonal to bottom base
        path.addLine(to: CGPoint(x: rect.midX + inset, y: rect.minY + height))
        
        // Bottom base (narrower than top but wider than before)
        path.addLine(to: CGPoint(x: rect.midX - inset, y: rect.minY + height))
        
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    MainView()
}
