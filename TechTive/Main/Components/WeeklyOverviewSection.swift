//
//  WeeklyOverviewSection.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct WeeklyOverviewSection: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Overview")
                .font(.custom("Poppins-Regular", size: 21))
                .foregroundColor(Color(UIColor.color.orange))
            
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

#Preview {
    WeeklyOverviewSection()
}
