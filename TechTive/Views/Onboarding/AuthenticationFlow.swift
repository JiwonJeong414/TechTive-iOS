//
//  AuthenticationFlow.swift
//  TechTive
//
//  A view that handles the authentication flow including onboarding and login process
//

import SwiftUI

struct AuthenticationFlow: View {
    
    // MARK: - Properties
    
    @State private var currentPage = 0
    @State private var showSignUp = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // MARK: - Constants
    
    private let backgrounds = [
        Color(Constants.Colors.lightPurple),
        Color(Constants.Colors.deepOrange),
        Color(Constants.Colors.warmOrange)
    ]
    
    private let images = ["pipe", "magnifying", "robot"]
    
    private let onboarding = ["Your Private ", "Understand Patterns", "Your Perspective"]
    
    private let onboardingTwo = [
        "Express yourself freely without the pressure of social media. Your thoughts stay completely private and secure.",
        "Our AI analyzes your entries to help you gain insights into your emotions and personality trends over time.",
        "Start your journey of self-discovery and growth!"
    ]
    
    private let sizex: [CGFloat] = [244, 168.94, 148]
    private let sizey: [CGFloat] = [132, 183, 264]
    
    // MARK: - UI
    
    var body: some View {
        VStack {
            if currentPage < 3 {
                onboardingView
            } else {
                loginView
            }
        }
    }
    
    // MARK: - UI Components
    
    private var onboardingView: some View {
        ZStack {
            backgrounds[currentPage]
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                onboardingImage
                Spacer().frame(height: 40)
                onboardingTitle
                onboardingDescription
                Spacer()
                navigationButtons
            }
        }
    }
    
    private var onboardingImage: some View {
        Image(images[currentPage])
            .resizable()
            .scaledToFit()
            .frame(
                width: sizex[currentPage],
                height: sizey[currentPage]
            )
            .foregroundColor(currentPage == 1 ? Color(Constants.Colors.white) : Color(Constants.Colors.orange))
    }
    
    private var onboardingTitle: some View {
        Text(onboarding[currentPage])
            .font(Constants.Fonts.poppinsMedium30)
            .bold()
            .foregroundColor(currentPage == 1 ? Color(Constants.Colors.white) : Color(Constants.Colors.black))
    }
    
    private var onboardingDescription: some View {
        Text(onboardingTwo[currentPage])
            .font(Constants.Fonts.poppinsRegular16)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .foregroundColor(currentPage == 1 ? Color(Constants.Colors.white).opacity(0.8) : Color(Constants.Colors.gray))
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentPage < 2 {
                skipButton
                Spacer()
                nextButton
            } else {
                getStartedButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private var skipButton: some View {
        Button("Skip") {
            withAnimation {
                currentPage = 3
            }
        }
        .foregroundColor(currentPage == 1 ? Color(Constants.Colors.white) : Color(Constants.Colors.gray))
    }
    
    private var nextButton: some View {
        Button {
            withAnimation {
                currentPage += 1
            }
        } label: {
            Text("Next")
                .foregroundColor(currentPage == 1 ? Color(Constants.Colors.white) : Color(Constants.Colors.gray))
                .fontWeight(.semibold)
        }
    }
    
    private var getStartedButton: some View {
        Button {
            withAnimation {
                currentPage += 1
            }
        } label: {
            Text("Get Started")
                .frame(maxWidth: .infinity)
                .padding()
                .font(Constants.Fonts.poppinsRegular16)
                .background(Color(Constants.Colors.lightPurple))
                .foregroundColor(Color(Constants.Colors.black))
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
