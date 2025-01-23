//
//  AuthenticationFlow.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI
struct AuthenticationFlow: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false
    @State private var currentPage = 0
    
    private let backgrounds = [Color(hex: "F3E5F5"), Color(hex: "E65100"), Color(hex: "FFF3E0")]
    private let images = ["pipe", "magnifying", "robot"]
    
    private let onboarding = ["Your Private Space", "Understand Patterns", "Your Perspective"]
    private let onboardingTwo = ["Express yourself freely without the pressure of social media. Your thoughts stay completely private and secure.", "Our AI analyzes your entries to help you gain insights into your emotions and personality trends over time.", "Start your journey of self-discovery and growth!"]

    private let sizex: [CGFloat] = [244, 168.94, 148].map { CGFloat($0) }
    private let sizey: [CGFloat] = [132, 183, 264].map { CGFloat($0) }
    
    var body: some View {
        VStack {
            if currentPage < 3 {
                // Onboarding Pages 
                ZStack {
                    backgrounds[currentPage]
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        
                        // Icon
                        Image(images[currentPage])
                            .resizable()
                            .scaledToFit()
                            .frame(width: sizex[currentPage], height: sizey[currentPage])
                            .foregroundColor(currentPage == 1 ? .white : .orange)
                        
                        Spacer()
                            .frame(height: 40)
                        
                        // Title
                        Text(onboarding[currentPage])
                            .font(.custom("Poppins-Medium", fixedSize: 30))
                            .bold()
                            .foregroundColor(currentPage == 1 ? .white : .black)
                        
                        // Description
                        Text(onboardingTwo[currentPage])
                            .font(.custom("Poppins-Regular", fixedSize: 16))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .foregroundColor(currentPage == 1 ? .white.opacity(0.8) : .gray)
                        
                        Spacer()
                        
                        // Navigation Buttons
                        HStack {
                            if currentPage < 2 {
                                Button("Skip") {
                                    withAnimation {
                                        currentPage = 3
                                    }
                                }
                                .foregroundColor(currentPage == 1 ? .white : .gray)
                                
                                Spacer()
                                Button {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                } label: {
                                    Text("Next")
                                        .foregroundColor(currentPage == 1 ? .white : .gray)
                                        .fontWeight(.semibold)
                                }
                            } else {
                                Button {
                                    withAnimation {
                                        currentPage += 1
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
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            } else {
                // Login Flow
                VStack {
                    LoginView()
                }
            }
        }
    }
}

// Helper extension for hex colors
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    AuthenticationFlow()
}
