//
//  Note.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct Note: Identifiable, Codable {
    let id: UUID
    let content: String
    let timestamp: Date
    let userId: String
    
    init(id: UUID = UUID(), content: String, userId: String) {
        self.id = id
        self.content = content
        self.timestamp = Date()
        self.userId = userId
    }
}
