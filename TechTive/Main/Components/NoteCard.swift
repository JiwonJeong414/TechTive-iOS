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
    
    var body: some View {
        HStack(spacing: 0) {
            // Left tab
            TrapezoidShape()
                .fill(backgroundForIndex(index)) // Change color to fit your theme
                 .frame(width: 40, height: 10) // Adjust size as needed
                 .offset(x: 11, y: -47) // Position the overlap
            
            
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
        .background(
            backgroundForIndex(index)

        )
    }
    
    private func backgroundForIndex(_ index: Int) -> Color {
        switch index % 4 {
            case 0: return Color(UIColor.color.purple)
            case 1: return Color(UIColor.color.lightOrange)
            case 2: return Color(UIColor.color.lightYellow)
            case 3: return Color(UIColor.color.purple)
            default: return Color(UIColor.color.lightYellow)
        }
    }
}

struct TrapezoidShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let inset: CGFloat = 25 // Made wider by increasing from 20 to 40
        let height: CGFloat = -15 // Kept the same height
        let baseWidth: CGFloat = 30 // Added wider base width
        
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
