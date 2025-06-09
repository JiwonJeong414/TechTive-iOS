import SwiftUI

extension AuthenticationFlow {
    class ViewModel: ObservableObject {
        @Published var currentPage = 0
        @Published var showSignUp = false

        // Onboarding data
        let backgrounds = [Color(hex: "F3E5F5"), Color(hex: "E65100"), Color(hex: "FFF3E0")]
        let images = ["pipe", "magnifying", "robot"]
        let onboarding = ["Your Private ", "Understand Patterns", "Your Perspective"]
        let onboardingTwo = [
            "Express yourself freely without the pressure of social media. Your thoughts stay completely private and secure.",
            "Our AI analyzes your entries to help you gain insights into your emotions and personality trends over time.",
            "Start your journey of self-discovery and growth!"
        ]
        let sizex: [CGFloat] = [244, 168.94, 148].map { CGFloat($0) }
        let sizey: [CGFloat] = [132, 183, 264].map { CGFloat($0) }

        func moveToNextPage() {
            withAnimation {
                self.currentPage += 1
            }
        }

        func skipToLogin() {
            withAnimation {
                self.currentPage = 3
            }
        }
    }
}
