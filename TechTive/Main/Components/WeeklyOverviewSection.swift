//
//  WeeklyOverviewSection.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct WeeklyOverviewSection: View {
    let isLimitedAccess: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Overview")
                .font(.title2)
                .bold()
            
            if isLimitedAccess {
                // Limited preview for non-authenticated users
                LimitedAccessPreview()
            } else {
                // Full weekly stats for authenticated users
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Text("Weekly Statistics/Charts")
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}

struct LimitedAccessPreview: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 100)
                .overlay(
                    Text("Preview Mode - Sign in to see full statistics")
                        .foregroundColor(.gray)
                )
            
            NavigationLink(destination: AuthenticationFlow()) {
                Text("Sign in to access all features")
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding(.top)
        }
    }
}

#Preview {
    WeeklyOverviewSection(isLimitedAccess: false)
}
