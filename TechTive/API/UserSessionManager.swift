//
//  UserSessionManager.swift
//  TechTive
//
//  Created by jiwon jeong on 10/14/25.
//

import Foundation
import FirebaseAuth
import os

class UserSessionManager: ObservableObject {
    static let shared = UserSessionManager()
    
    @Published var accessToken: String?
    @Published var userID: String?
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.techtive", category: "UserSession")
    
    private init() {}
    
    func getAuthToken() async throws -> String {
        guard let currentUser = Auth.auth().currentUser else {
            throw NetworkError.authenticationFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            currentUser.getIDToken { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let token = token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: NetworkError.authenticationFailed)
                }
            }
        }
    }
    
    func logout() {
        accessToken = nil
        userID = nil
    }
}
