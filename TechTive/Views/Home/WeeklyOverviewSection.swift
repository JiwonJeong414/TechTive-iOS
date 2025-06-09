import SwiftUI

/// Generates a Weekly Overview based on journals for the week
struct WeeklyOverviewSection: View {
    // MARK: - Properties

    @StateObject private var viewModel = ViewModel()

    private let stickyYellow = Color(red: 255 / 255, green: 251 / 255, blue: 181 / 255)
    private let foldYellow = Color(red: 255 / 255, green: 244 / 255, blue: 120 / 255)
    private let pinGray = Color.gray.opacity(0.7)

    // MARK: - UI

    var body: some View {
        ZStack {
            StickyNoteBackground(stickyColor: self.stickyYellow, foldColor: self.foldYellow)
                .frame(height: 180)
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)

            VStack(spacing: 0) {
                PinView(pinColor: self.pinGray)
                    .padding(.top, 8)

                Spacer(minLength: 0)

                self.contentSection

                Spacer(minLength: 0)
            }
            .frame(height: 180)
        }
        .padding(.horizontal, 24)
        .task {
            await self.viewModel.fetchWeeklyAdvice()
        }
    }

    @ViewBuilder private var contentSection: some View {
        if let adviceResponse = viewModel.weeklyAdvice {
            self.adviceText(adviceResponse)
        } else if let error = viewModel.errorMessage {
            self.errorView(error)
        } else {
            ProgressView()
        }
    }

    private func adviceText(_ response: WeeklyAdviceResponse) -> some View {
        Text(response.content)
            .font(.custom("CourierPrime-Regular", fixedSize: 17))
            .foregroundColor(.black.opacity(0.85))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: 120, alignment: .center)
    }

    private func errorView(_: String) -> some View {
        Text("Not Enough Notes")
            .font(.custom("CourierPrime-Regular", fixedSize: 17))
            .foregroundColor(.red)
            .padding()
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: 120, alignment: .center)
    }
}
