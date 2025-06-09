import SwiftUI

/// A view that handles the authentication flow including onboarding and login process
struct AuthenticationFlow: View {
    // MARK: - Properties

    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false
    @State private var currentPage = 0

    private let backgrounds = [Color(hex: "F3E5F5"), Color(hex: "E65100"), Color(hex: "FFF3E0")]
    private let images = ["pipe", "magnifying", "robot"]
    private let onboarding = ["Your Private ", "Understand Patterns", "Your Perspective"]
    private let onboardingTwo = [
        "Express yourself freely without the pressure of social media. Your thoughts stay completely private and secure.",
        "Our AI analyzes your entries to help you gain insights into your emotions and personality trends over time.",
        "Start your journey of self-discovery and growth!"
    ]
    private let sizex: [CGFloat] = [244, 168.94, 148].map { CGFloat($0) }
    private let sizey: [CGFloat] = [132, 183, 264].map { CGFloat($0) }

    // MARK: - UI

    var body: some View {
        VStack {
            if self.currentPage < 3 {
                self.onboardingView
            } else {
                self.loginView
            }
        }
    }

    // MARK: - UI Components

    private var onboardingView: some View {
        ZStack {
            self.backgrounds[self.currentPage]
                .ignoresSafeArea()

            VStack {
                Spacer()
                self.onboardingImage
                Spacer().frame(height: 40)
                self.onboardingTitle
                self.onboardingDescription
                Spacer()
                self.navigationButtons
            }
        }
    }

    private var onboardingImage: some View {
        Image(self.images[self.currentPage])
            .resizable()
            .scaledToFit()
            .frame(width: self.sizex[self.currentPage], height: self.sizey[self.currentPage])
            .foregroundColor(self.currentPage == 1 ? .white : .orange)
    }

    private var onboardingTitle: some View {
        Text(self.onboarding[self.currentPage])
            .font(.custom("Poppins-Medium", fixedSize: 30))
            .bold()
            .foregroundColor(self.currentPage == 1 ? .white : .black)
    }

    private var onboardingDescription: some View {
        Text(self.onboardingTwo[self.currentPage])
            .font(.custom("Poppins-Regular", fixedSize: 16))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .foregroundColor(self.currentPage == 1 ? .white.opacity(0.8) : .gray)
    }

    private var navigationButtons: some View {
        HStack {
            if self.currentPage < 2 {
                self.skipButton
                Spacer()
                self.nextButton
            } else {
                self.getStartedButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }

    private var skipButton: some View {
        Button("Skip") {
            withAnimation {
                self.currentPage = 3
            }
        }
        .foregroundColor(self.currentPage == 1 ? .white : .gray)
    }

    private var nextButton: some View {
        Button {
            withAnimation {
                self.currentPage += 1
            }
        } label: {
            Text("Next")
                .foregroundColor(self.currentPage == 1 ? .white : .gray)
                .fontWeight(.semibold)
        }
    }

    private var getStartedButton: some View {
        Button {
            withAnimation {
                self.currentPage += 1
            }
        } label: {
            Text("Get Started")
                .frame(maxWidth: .infinity)
                .padding()
                .font(.custom("Poppins-Regular", fixedSize: 16))
                .background(Color(hex: "F3E5F5"))
                .foregroundColor(.black)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    private var loginView: some View {
        VStack {
            LoginView()
        }
    }
}

// MARK: - Helper Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255)
    }
}
