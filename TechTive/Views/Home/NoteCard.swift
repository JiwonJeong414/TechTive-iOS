import SwiftUI

/// A card view that displays a single note with its content, date, and emotion analysis
struct NoteCard: View {
    // MARK: - Properties

    let note: Note
    let index: Int
    @ObservedObject var noteViewModel: NotesViewModel

    @State private var trapezoidPosition: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var showingGraph = false
    @State private var hasAppeared = false

    // MARK: - Constants

    private let animationSpeed: CGFloat = 2.0
    private let startingOffset: CGFloat = 0

    // MARK: - Formatters

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        return formatter
    }()

    // MARK: - Helper Methods

    private func calculateOffset() -> CGFloat {
        let baseOffset = CGFloat(index * 50 + 11)
        let screenHeight = UIScreen.main.bounds.height
        let adjustedPosition = self.trapezoidPosition * self.animationSpeed
        let scrollProgress = min(max(adjustedPosition / screenHeight, 0), 1)
        let maxMovement: CGFloat = 400
        return (baseOffset + self.startingOffset) - ((1 - scrollProgress) * maxMovement)
    }

    private func backgroundForIndex(_ index: Int) -> Color {
        switch index % 3 {
            case 0: return Color(Constants.Colors.purple)
            case 1: return Color(Constants.Colors.lightOrange)
            case 2: return Color(Constants.Colors.lightYellow)
            default: return Color(Constants.Colors.lightYellow)
        }
    }

    private var isEmotionLoading: Bool {
        return self.note.angerValue == 0 &&
            self.note.disgustValue == 0 &&
            self.note.fearValue == 0 &&
            self.note.joyValue == 0 &&
            self.note.neutralValue == 0 &&
            self.note.sadnessValue == 0 &&
            self.note.surpriseValue == 0
    }

    // MARK: - UI

    var body: some View {
        GeometryReader { mainGeo in
            HStack(spacing: 0) {
                self.trapezoidView

                VStack(alignment: .leading, spacing: 4) {
                    self.noteContent
                    self.noteFooter
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 105)
            .background(self.backgroundForIndex(self.index))
            .offset(x: self.offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.hasAppeared = true
                }
            }
            .onChange(of: self.noteViewModel.notes.count) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.trapezoidPosition = mainGeo.frame(in: .global).minY
                }
            }
            .popover(isPresented: self.$showingGraph) {
                GraphView(note: self.note)
                    .frame(width: 300, height: 300)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }

    private var noteContent: some View {
        HStack {
            Text(self.note.content)
                .font(.custom("CourierPrime-Regular", fixedSize: 18))
                .foregroundColor(Color(Constants.Colors.orange))
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(Constants.Colors.orange))
        }
    }

    private var noteFooter: some View {
        HStack {
            Text(self.dateFormatter.string(from: self.note.timestamp))
                .font(.custom("Poppins-Regular", fixedSize: 14))
                .foregroundColor(Color(Constants.Colors.darkPurple))

            Spacer()

            self.emotionButton
        }
    }

    private var emotionButton: some View {
        Button(action: {
            self.showingGraph = true
        }) {
            HStack(spacing: 4) {
                Text(self.isEmotionLoading ? "Loading" : self.note.dominantEmotion.emotion)
                    .font(.custom("Poppins-Regular", fixedSize: 12))
                    .foregroundColor(Color(Constants.Colors.darkPurple))
                if self.isEmotionLoading {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(Color(Constants.Colors.darkPurple))
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(Constants.Colors.darkPurple).opacity(0.1)))
        }
    }

    private var trapezoidView: some View {
        TrapezoidShape()
            .fill(self.backgroundForIndex(self.index))
            .frame(width: 40, height: 10)
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            self.trapezoidPosition = geometry.frame(in: .global).minY
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.trapezoidPosition = newValue
                            }
                        }
                })
            .offset(x: self.calculateOffset(), y: -47)
            .id("trapezoid-\(self.note.id)")
    }
}
