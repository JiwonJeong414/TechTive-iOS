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
                                .onChange(of: geometry.frame(in: .global).minY) { position in
                                    trapezoidPosition = position
                                    print("Trapezoid \(index) Y position: \(position)")
                                }
                        }
                    )
                    .offset(x: calculateOffset(), y: -47)
                
                // Main content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Title of File")
                            .font(.custom("CourierPrime-Regular", size: 18))
                            .foregroundColor(Color(UIColor.color.orange))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    
                    Text(note.timestamp, style: .date)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
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
        let scrollProgress = trapezoidPosition / screenHeight
        
        // Move left as the card moves up the screen
        // Adjust these values to control the movement
        let maxMovement: CGFloat = 100
        return baseOffset - (scrollProgress * maxMovement)
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
    MainView(isLimitedAccess: false)
}
