import SwiftUI

struct PinView: View {
    let pinColor: Color
    var body: some View {
        ZStack {
            Circle()
                .fill(self.pinColor)
                .frame(width: 18, height: 18)
                .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 8, height: 8)
        }
        .frame(height: 24)
        .padding(.top, 0)
    }
}
