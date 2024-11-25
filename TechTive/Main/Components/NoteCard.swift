//
//  NoteCard.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct NoteCard: View {
    let note: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(note)
                .font(.body)
            
            HStack {
                Text("Date")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                // Add any interaction buttons here
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
