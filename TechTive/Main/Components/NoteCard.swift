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
    @ObservedObject var noteViewModel: NotesViewModel
    @State private var offset: CGFloat = 0
    @State private var showingGraph = false
    @State private var hasAppeared = false

    
    private let animationSpeed: CGFloat = 2.0
    private let startingOffset: CGFloat = 0
    
    private var isEmotionLoading: Bool {
        return note.angerValue == 0 &&
               note.disgustValue == 0 &&
               note.fearValue == 0 &&
               note.joyValue == 0 &&
               note.neutralValue == 0 &&
               note.sadnessValue == 0 &&
               note.surpriseValue == 0
    }
    
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        return formatter
    }()
    
    var body: some View {
        GeometryReader { mainGeo in
            HStack(spacing: 0) {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(note.content)
                            .font(.custom("CourierPrime-Regular", size: 18))
                            .foregroundColor(Color(UIColor.color.orange))
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    
                    HStack {
                        Text(dateFormatter.string(from: note.timestamp))
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color(UIColor.color.darkPurple))
                        
                        Spacer()
                        
                        // Modified emotion button
                        Button(action: {
                            showingGraph = true
                        }) {
                            HStack(spacing: 4) {
                                Text(isEmotionLoading ? "Loading" : note.dominantEmotion.emotion)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(UIColor.color.darkPurple))
                                
                                Image(systemName: isEmotionLoading ? "clock" : "chart.radar")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(UIColor.color.darkPurple))
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.color.darkPurple).opacity(0.1))
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 105)
            .background(backgroundForIndex(index))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            offset = gesture.translation.width
                        }
                    }
                    .onEnded { gesture in
                        withAnimation {
                            if gesture.translation.width < -100 {
                                noteViewModel.deleteNote(note)
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
            .popover(isPresented: $showingGraph) {
                GraphView(note: note)
                    .frame(width: 300, height: 300)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }
    
    private func calculateOffset() -> CGFloat {
        let baseOffset = CGFloat(index * 50 + 11)
        let screenHeight = UIScreen.main.bounds.height
        let adjustedPosition = trapezoidPosition * animationSpeed
        let scrollProgress = min(max(adjustedPosition / screenHeight, 0), 1)
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

struct EmotionsGraphModal: View {
    @Environment(\.dismiss) var dismiss
    let note: Note
    
    var body: some View {
        NavigationView {
            GraphView(note: note)
                .navigationBarItems(
                    trailing: Button("Done") {
                        dismiss()
                    }
                )
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
        .environmentObject(AuthViewModel())
    
}
