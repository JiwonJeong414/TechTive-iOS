import Alamofire
import SwiftUI

enum WeeklyTab {
    case overview
    case riddle
}

struct TabShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Start from bottom left
        path.move(to: CGPoint(x: 0, y: height))
        // Line to top left with inset
        path.addLine(to: CGPoint(x: width * 0.1, y: 0))
        // Line to top right with inset
        path.addLine(to: CGPoint(x: width * 0.9, y: 0))
        // Line to bottom right
        path.addLine(to: CGPoint(x: width, y: height))

        return path
    }
}

struct WeeklyOverviewSection: View {
    @StateObject private var viewModel = WeeklyAdviceViewModel()
    @State private var selectedTab: WeeklyTab = .overview
    @State private var riddleAnswer = ""
    @State private var hasAnsweredCorrectly = false
    @State private var showIncorrectFeedback = false
    @AppStorage("riddleAnswered") private var riddleAnswered = false

    private let cream = Color(red: 252 / 255, green: 247 / 255, blue: 230 / 255)
    private let peach = Color(red: 255 / 255, green: 236 / 255, blue: 227 / 255)
    private let coral = Color(red: 241 / 255, green: 90 / 255, blue: 35 / 255)

    var body: some View {
        VStack(spacing: 0) {
            // Folder tabs with shadow effect
            ZStack(alignment: .top) {
                HStack(spacing: -2) {
                    ForEach([WeeklyTab.overview, .riddle], id: \.self) { tab in
                        Button(action: { withAnimation { self.selectedTab = tab } }) {
                            ZStack {
                                // Shadow layer
                                if self.selectedTab != tab {
                                    TabShape()
                                        .fill(Color.black.opacity(0.1))
                                        .offset(y: 1)
                                }

                                // Tab background
                                TabShape()
                                    .fill(self.selectedTab == tab ? self.cream : self.peach)

                                // Tab content
                                Text(tab == .overview ? "Overview" : "Riddle")
                                    .font(.custom("Poppins-Regular", fixedSize: 16))
                                    .foregroundColor(self.selectedTab == tab ? self.coral : .black.opacity(0.6))
                                    .padding(.bottom, 4)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width / 2.2, height: 40)
                        .zIndex(self.selectedTab == tab ? 1 : 0)
                    }
                }
            }

            // Content area with shadow effect
            VStack {
                if let adviceResponse = viewModel.weeklyAdvice {
                    if self.selectedTab == .overview {
                        self.overviewContent(adviceResponse)
                            .transition(.opacity)
                    } else {
                        self.riddleContent(adviceResponse)
                            .transition(.opacity)
                    }
                } else if let error = viewModel.errorMessage {
                    self.errorView(error)
                } else {
                    ProgressView()
                }
            }
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(self.selectedTab == .overview ? self.cream : self.peach)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1))
        }
        .task {
            await self.viewModel.fetchWeeklyAdvice()
            if self.viewModel.weeklyAdvice != nil {
                self.hasAnsweredCorrectly = self.riddleAnswered
            }
        }
    }

    private func overviewContent(_ response: WeeklyAdviceResponse) -> some View {
        ScrollView {
            Text(response.advice.content?.advice ?? "Not enough notes yet to give advice.")
                .font(.custom("CourierPrime-Regular", fixedSize: 17))
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .frame(width: UIScreen.main.bounds.width - 36, height: 160)
        }
    }

    private func riddleContent(_ response: WeeklyAdviceResponse) -> some View {
        VStack(spacing: 16) {
            ScrollView {
                Text(response.advice.content?.riddle ?? "No riddle available")
                    .font(.custom("CourierPrime-Regular", fixedSize: 17))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !self.hasAnsweredCorrectly {
                VStack(spacing: 12) {
                    TextField("Your answer", text: self.$riddleAnswer)
                        .textFieldStyle(WeeklyRiddleTextFieldStyle())
                        .padding(.horizontal, 20)

                    if self.showIncorrectFeedback {
                        Text("Incorrect, try again!")
                            .font(.custom("Poppins-Regular", fixedSize: 15))
                            .foregroundColor(.red)
                            .transition(.opacity)
                    }

                    Button(action: {
                        self.checkAnswer(response.advice.content?.answer ?? "")
                    }) {
                        Text("Check Answer")
                            .font(.custom("Poppins-Regular", fixedSize: 16))
                            .foregroundColor(self.coral)
                            .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 32))

                    Text("Correct!")
                        .font(.custom("Poppins-Regular", fixedSize: 17))
                        .foregroundColor(.green)

                    Text("Answer: \(response.advice.content?.answer ?? "")")
                        .font(.custom("CourierPrime-Regular", fixedSize: 15))
                        .foregroundColor(.black.opacity(0.6))

                    Button(action: self.resetRiddle) {
                        Text("Reset")
                            .font(.custom("Poppins-Regular", fixedSize: 16))
                            .foregroundColor(self.coral)
                            .padding(.vertical, 8)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
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

    private func checkAnswer(_ correctAnswer: String) {
        let userAnswerTrimmed = self.riddleAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correctAnswerTrimmed = correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        withAnimation {
            if userAnswerTrimmed == correctAnswerTrimmed {
                self.hasAnsweredCorrectly = true
                self.riddleAnswered = true
                self.showIncorrectFeedback = false
            } else {
                self.showIncorrectFeedback = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        self.showIncorrectFeedback = false
                    }
                }
            }
        }
    }

    private func resetRiddle() {
        withAnimation {
            self.riddleAnswer = ""
            self.hasAnsweredCorrectly = false
            self.riddleAnswered = false
            self.showIncorrectFeedback = false
        }
    }
}

struct WeeklyRiddleTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom("CourierPrime-Regular", size: 16))
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1))
    }
}
