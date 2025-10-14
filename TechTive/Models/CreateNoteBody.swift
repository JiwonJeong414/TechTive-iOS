//
//  CreateNoteBody.swift
//  TechTive
//
//  Created by jiwon jeong on 10/14/25.
//
import Foundation

/// Request body for creating a new note
struct CreateNoteBody: Encodable {
    let content: String
    let formattings: [FormattingData]
    
    struct FormattingData: Encodable {
        let type: String
        let location: Int
        let length: Int
    }
}
