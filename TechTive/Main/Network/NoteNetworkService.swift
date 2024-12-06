//
//  NoteNetworkService.swift
//  TechTive
//
//  Created by jiwon jeong on 12/6/24.
//

import Foundation
import SwiftUI
import Alamofire

struct NoteResponse: Codable {
    let message: String
    let note: Note?
    let notes: [Note]?
}

class NoteNetworkService: ObservableObject {
    private let baseURL = "https://631c-128-84-124-32.ngrok-free.app/api/"
    
    // Create a new note with formatting
    func createNote(attributedString: NSAttributedString, userId: String) async throws -> NoteResponse {
        let note = Note(attributedString: attributedString, userId: userId)
        
        // Configure date encoding strategy
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return try await AF.request("\(baseURL)/posts/",
                                    method: .post,
                                    parameters: note,
                                    encoder: encoder as! ParameterEncoder)
        .serializingDecodable(NoteResponse.self)
        .value
    }
    
    // Get notes for a user and convert them back to attributed strings
    func getNotes(userId: String) async throws -> NoteResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try await AF.request("\(baseURL)/posts/",
                                    method: .get)
        .serializingDecodable(NoteResponse.self, decoder: decoder)
        .value
    }
}
