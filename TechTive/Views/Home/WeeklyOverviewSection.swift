import SwiftUI

struct WeeklyOverviewSection: View {
    @StateObject private var viewModel = WeeklyAdviceViewModel()

    private let cream = Color(red: 252 / 255, green: 247 / 255, blue: 230 / 255)

    var body: some View {
        VStack {
            if let adviceResponse = viewModel.weeklyAdvice {
                self.overviewContent(adviceResponse)
            } else if let error = viewModel.errorMessage {
                self.errorView(error)
            } else {
                ProgressView()
            }
        }
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(self.cream)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1))
        .task {
            await self.viewModel.fetchWeeklyAdvice()
        }
    }

    private func overviewContent(_ response: WeeklyAdviceResponse) -> some View {
        ScrollView {
            Text(response.content)
                .font(.custom("CourierPrime-Regular", fixedSize: 17))
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .frame(width: UIScreen.main.bounds.width - 36, height: 160)
        }
    }

    private func errorView(_: String) -> some View {
        Text("Not Enough Notes")
            .font(.custom("CourierPrime-Regular", fixedSize: 17))
            .foregroundColor(.red)
            .padding()
            .multilineTextAlignment(.center)
            .frame(width: UIScreen.main.bounds.width - 38, height: 160)
    }
}
