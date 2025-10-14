//
//  ErrorResponse.swift
//  TechTive
//
//  Created by jiwon jeong on 10/14/25.
//

struct ErrorResponse: Codable, Error {
    let error: String
    let httpCode: Int
}

enum NetworkError: Error {
    case invalidImageData
    case invalidResponse
    case authenticationFailed
    case noDataAvailable
    
    var localizedDescription: String {
        switch self {
        case .invalidImageData: return "Invalid image data"
        case .invalidResponse: return "Invalid response from server"
        case .authenticationFailed: return "Authentication failed"
        case .noDataAvailable: return "No data available"
        }
    }
}
