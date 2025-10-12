import SwiftUI

/// Generates a Weekly Overview based on journals for the week
struct WeeklyOverviewSection: View {
    // MARK: - Properties

    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    private let stickyYellow = Color(Constants.Colors.stickyYellow)
    private let foldYellow = Color(Constants.Colors.foldYellow)
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
            self.viewModel.setAuthViewModel(self.authViewModel)
            await self.viewModel.fetchWeeklyAdvice()
        }
    }

    @ViewBuilder private var contentSection: some View {
        if let adviceResponse = viewModel.weeklyAdvice {
            self.adviceText(adviceResponse)
        } else if let error = viewModel.errorMessage {
            self.errorView(error)
        } else {
            self.emptyStateView()
        }
    }

    private func adviceText(_ response: WeeklyAdviceResponse) -> some View {
        VStack(spacing: 8) {
            Text("Weekly Riddle")
                .font(Constants.Fonts.poppinsSemiBold14)
                .foregroundColor(Color(Constants.Colors.black).opacity(0.9))

            Text(response.safeContent.riddle)
                .font(.custom("CourierPrime-Regular", fixedSize: 15))
                .foregroundColor(Color(Constants.Colors.black).opacity(0.8))
                .multilineTextAlignment(.center)

            Text("Answer: \(response.safeContent.answer)")
                .font(Constants.Fonts.poppinsMedium14)
                .foregroundColor(Color(Constants.Colors.orange))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: 120, alignment: .center)
    }

    private func errorView(_: String) -> some View {
        Text("Not Enough Notes")
            .font(Constants.Fonts.courierPrime17)
            .foregroundColor(Color(Constants.Colors.red))
            .padding()
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: 120, alignment: .center)
    }

    private func emptyStateView() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "lightbulb")
                .font(.system(size: 24))
                .foregroundColor(Color(Constants.Colors.gray).opacity(0.5))

            Text("No weekly advice available")
                .font(Constants.Fonts.poppinsRegular14)
                .foregroundColor(Color(Constants.Colors.gray))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: 120, alignment: .center)
    }
}
