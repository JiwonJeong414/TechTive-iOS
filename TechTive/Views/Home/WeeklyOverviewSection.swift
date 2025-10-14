//
//  WeeklyOverviewSection.swift
//  TechTive
//
//  Generates a Weekly Overview based on journals for the week
//

import SwiftUI

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
            StickyNoteBackground(stickyColor: stickyYellow, foldColor: foldYellow)
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
            
            VStack(spacing: 0) {
                PinView(pinColor: pinGray)
                    .padding(.top, 8)
                
                contentSection
                    .padding(.bottom, 16)
            }
        }
        .frame(minHeight: 160)
        .padding(.horizontal, 24)
        .task {
            await viewModel.fetchWeeklyAdvice()
        }
    }
    
    @ViewBuilder private var contentSection: some View {
        if let adviceResponse = viewModel.weeklyAdvice {
            adviceText(adviceResponse)
        } else if let error = viewModel.errorMessage {
            errorView(error)
        } else {
            emptyStateView()
        }
    }
    
    private func adviceText(_ response: WeeklyAdviceResponse) -> some View {
        VStack(spacing: 8) {
            Text("Weekly Advice")
                .font(Constants.Fonts.poppinsSemiBold14)
                .foregroundColor(Color(Constants.Colors.black).opacity(0.9))
            
            Text(response.content)
                .font(.custom("CourierPrime-Regular", fixedSize: 14))
                .foregroundColor(Color(Constants.Colors.black).opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .center)
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

// MARK: - ViewModel

extension WeeklyOverviewSection {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        // MARK: - Published Properties
        
        @Published var weeklyAdvice: WeeklyAdviceResponse?
        @Published var errorMessage: String?
        
        // MARK: - Methods
        
        func fetchWeeklyAdvice() async {
            do {
                let response = try await NetworkManager.shared.getLatestAdvice()
                
                await MainActor.run {
                    weeklyAdvice = response
                    errorMessage = nil
                }
            } catch {
                print("Error fetching weekly advice: \(error)")
                await MainActor.run {
                    if (error as? ErrorResponse)?.httpCode == 404 {
                        errorMessage = "Not enough notes for weekly advice"
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    weeklyAdvice = nil
                }
            }
        }
    }
}
