//
//  NetworkManager.swift
//  TechTive
//
//  Created by jiwon jeong on 10/14/25.
//

import Foundation
import UIKit
import Alamofire
import os

class NetworkManager: APIClient {
    static let shared = NetworkManager()
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.techtive", category: "Network")
    
    private let hostURL: String = Constants.API.baseURL
    
    private init() {}
    
    // MARK: - Generic Methods
    
    func get<T: Decodable>(url: URL) async throws -> T {
        let request = try createRequest(url: url, method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func post<T: Decodable, U: Encodable>(url: URL, body: U) async throws -> T {
        let requestData = try JSONEncoder().encode(body)
        let request = try createRequest(url: url, method: "POST", body: requestData)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func post<T: Decodable>(url: URL) async throws -> T {
        let request = try createRequest(url: url, method: "POST")
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func delete(url: URL) async throws {
        let request = try createRequest(url: url, method: "DELETE")
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(data: data, response: response)
    }
    
    // MARK: - Helper Methods
    
    private func createRequest(url: URL, method: String, body: Data? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get token from UserSessionManager
        if let accessToken = UserSessionManager.shared.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        return request
    }
    
    private func constructURL(endpoint: String) throws -> URL {
        guard let url = URL(string: "\(hostURL)\(endpoint)") else {
            logger.error("Failed to construct URL for endpoint: \(endpoint)")
            throw URLError(.badURL)
        }
        return url
    }
    
    private func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Accept both 200 and 201 (201 is standard for POST create operations)
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                logger.error("Server error: \(errorResponse.error) (HTTP \(errorResponse.httpCode))")
                throw errorResponse
            } else {
                logger.error("HTTP error: \(httpResponse.statusCode)")
                throw URLError(.init(rawValue: httpResponse.statusCode))
            }
        }
    }
    
    // MARK: - API Methods
    
    // Notes
    func getNotes() async throws -> NotesResponse {
        let url = try constructURL(endpoint: Constants.API.notes)
        return try await get(url: url)
    }
    
    func getNote(id: Int) async throws -> Note {
        let url = try constructURL(endpoint: "\(Constants.API.notes)\(id)/")
        return try await get(url: url)
    }
    
    func createNote(body: CreateNoteBody) async throws -> Note {
        let url = try constructURL(endpoint: Constants.API.notes)
        return try await post(url: url, body: body)
    }
    
    func deleteNote(id: Int) async throws {
        let url = try constructURL(endpoint: "\(Constants.API.notes)\(id)/")
        try await delete(url: url)
    }
    
    // Quotes
    func getRandomQuote() async throws -> QuoteResponse {
        let url = try constructURL(endpoint: Constants.API.quotes)
        return try await get(url: url)
    }
    
    // Weekly Advice
    func getLatestAdvice() async throws -> WeeklyAdviceResponse {
        let url = try constructURL(endpoint: Constants.API.advice)
        return try await get(url: url)
    }
    
    // MARK: - Profile Picture Methods

    func getProfilePicture() async throws -> UIImage? {
        let url = try constructURL(endpoint: Constants.API.profilePicture)
        
        // Make request with auth token
        let request = try createRequest(url: url, method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check if response is 404 (no profile picture)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 {
                return nil // No profile picture found
            }
            
            try handleResponse(data: data, response: response)
        }
        
        guard let image = UIImage(data: data) else {
            throw NetworkError.invalidImageData
        }
        
        return image
    }

    func uploadProfilePicture(image: UIImage) async throws -> ProfilePictureResponse {
        let url = Constants.API.baseURL + Constants.API.profilePicture
        
        guard let token = UserSessionManager.shared.accessToken else {
            throw NetworkError.authenticationFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                continuation.resume(throwing: NetworkError.invalidImageData)
                return
            }
            
            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
            
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        imageData,
                        withName: "profile_picture",
                        fileName: "profile.jpg",
                        mimeType: "image/jpeg"
                    )
                },
                to: url,
                headers: headers
            )
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(ProfilePictureResponse.self, from: data)
                        continuation.resume(returning: decoded)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func updateProfilePicture(image: UIImage) async throws -> ProfilePictureResponse {
        let url = Constants.API.baseURL + Constants.API.profilePicture
        
        guard let token = UserSessionManager.shared.accessToken else {
            throw NetworkError.authenticationFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                continuation.resume(throwing: NetworkError.invalidImageData)
                return
            }
            
            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
            
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        imageData,
                        withName: "profile_picture",
                        fileName: "profile.jpg",
                        mimeType: "image/jpeg"
                    )
                },
                to: url,
                method: .put,  // ✅ Use PUT for updates
                headers: headers
            )
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(ProfilePictureResponse.self, from: data)
                        continuation.resume(returning: decoded)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
