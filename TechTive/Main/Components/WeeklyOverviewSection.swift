//
//  WeeklyOverviewSection.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct WeeklyOverviewSection: View {
    @StateObject private var viewModel = WeeklyAdviceViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Overview")
                .font(.custom("Poppins-Regular", size: 21))
                .foregroundColor(Color(UIColor.color.orange))
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Text(viewModel.weeklyAdvice)
                            .foregroundColor(.primary)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                )
        }
        .onAppear {
            viewModel.fetchWeeklyAdvice()
        }
    }
}


#Preview {
    WeeklyOverviewSection()
}
