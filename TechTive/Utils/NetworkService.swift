import Alamofire
import Foundation
import UIKit

/// Simple network service extension with generic functions
extension URLSession {
    /// Generic GET request with Bearer token authentication
    static func get<T: Codable>(
        endpoint: String,
        token: String,
        responseType: T.Type) async throws -> T
    {
        let url = Constants.API.baseURL + endpoint
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        // Check if response is HTML (error page)
        if let httpResponse = response as? HTTPURLResponse {
            let contentType = httpResponse.allHeaderFields["Content-Type"] as? String ?? ""
            if contentType.contains("text/html") {
                print("❌ Server returned HTML instead of JSON for endpoint: \(endpoint)")
                print("❌ Response status: \(httpResponse.statusCode)")
                if let htmlString = String(data: data, encoding: .utf8) {
                    print("❌ HTML response: \(htmlString.prefix(200))...")
                }
                throw NetworkError.invalidResponse
            }

            if httpResponse.statusCode >= 400 {
                print("❌ HTTP Error \(httpResponse.statusCode) for endpoint: \(endpoint)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error response: \(errorString)")
                }
                throw NetworkError.invalidResponse
            }
        }

        return try JSONDecoder().decode(responseType, from: data)
    }

    /// Generic POST request with Bearer token authentication
    static func post<T: Codable>(
        endpoint: String,
        token: String,
        parameters: [String: Any],
        responseType: T.Type) async throws -> T
    {
        let url = Constants.API.baseURL + endpoint
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)

        let (data, response) = try await URLSession.shared.data(for: request)

        // Check if response is HTML (error page)
        if let httpResponse = response as? HTTPURLResponse {
            let contentType = httpResponse.allHeaderFields["Content-Type"] as? String ?? ""
            if contentType.contains("text/html") {
                print("❌ Server returned HTML instead of JSON for POST endpoint: \(endpoint)")
                print("❌ Response status: \(httpResponse.statusCode)")
                if let htmlString = String(data: data, encoding: .utf8) {
                    print("❌ HTML response: \(htmlString.prefix(200))...")
                }
                throw NetworkError.invalidResponse
            }

            if httpResponse.statusCode >= 400 {
                print("❌ HTTP Error \(httpResponse.statusCode) for POST endpoint: \(endpoint)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error response: \(errorString)")
                }
                throw NetworkError.invalidResponse
            }
        }

        return try JSONDecoder().decode(responseType, from: data)
    }

    /// Generic PUT request with Bearer token authentication
    static func put<T: Codable>(
        endpoint: String,
        token: String,
        parameters: [String: Any],
        responseType: T.Type) async throws -> T
    {
        let url = Constants.API.baseURL + endpoint
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(responseType, from: data)
    }

    /// Generic DELETE request with Bearer token authentication
    static func delete<T: Codable>(
        endpoint: String,
        token: String,
        responseType: T.Type) async throws -> T
    {
        let url = Constants.API.baseURL + endpoint
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(responseType, from: data)
    }

    /// Upload image with multipart form data
    static func uploadImage<T: Codable>(
        endpoint: String,
        token: String,
        image: UIImage,
        responseType: T.Type) async throws -> T
    {
        let url = Constants.API.baseURL + endpoint

        return try await withCheckedThrowingContinuation { continuation in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                continuation.resume(throwing: NetworkError.invalidImageData)
                return
            }

            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)"
            ]

            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        imageData,
                        withName: "profile_picture",
                        fileName: "profile.jpg",
                        mimeType: "image/jpeg")
                },
                to: url,
                headers: headers)
                .validate()
                .responseData { response in
                    // Debug: Print response details
                    if let httpResponse = response.response {
                        print("📤 Image upload response status: \(httpResponse.statusCode)")
                    }

                    switch response.result {
                        case let .success(data):
                            do {
                                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                                print("✅ Image upload successful")
                                continuation.resume(returning: decodedResponse)
                            } catch {
                                print("❌ Image upload decoding error: \(error)")
                                if let jsonString = String(data: data, encoding: .utf8) {
                                    print("❌ Response data: \(jsonString)")
                                }
                                continuation.resume(throwing: error)
                            }
                        case let .failure(error):
                            print("❌ Image upload error: \(error)")
                            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                                print("❌ Error response data: \(jsonString)")
                            }
                            continuation.resume(throwing: error)
                    }
                }
        }
    }

    /// Upload image with multipart form data using PUT method (for updates)
    static func uploadImageUpdate<T: Codable>(
        endpoint: String,
        token: String,
        image: UIImage,
        responseType: T.Type) async throws -> T
    {
        let url = Constants.API.baseURL + endpoint

        return try await withCheckedThrowingContinuation { continuation in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                continuation.resume(throwing: NetworkError.invalidImageData)
                return
            }

            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)"
            ]

            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        imageData,
                        withName: "profile_picture",
                        fileName: "profile.jpg",
                        mimeType: "image/jpeg")
                },
                to: url,
                method: .put,
                headers: headers)
                .validate()
                .responseData { response in
                    // Debug: Print response details
                    if let httpResponse = response.response {
                        print("📤 Image update response status: \(httpResponse.statusCode)")
                    }

                    switch response.result {
                        case let .success(data):
                            do {
                                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                                print("✅ Image update successful")
                                continuation.resume(returning: decodedResponse)
                            } catch {
                                print("❌ Image update decoding error: \(error)")
                                if let jsonString = String(data: data, encoding: .utf8) {
                                    print("❌ Response data: \(jsonString)")
                                }
                                continuation.resume(throwing: error)
                            }
                        case let .failure(error):
                            print("❌ Image update error: \(error)")
                            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                                print("❌ Error response data: \(jsonString)")
                            }
                            continuation.resume(throwing: error)
                    }
                }
        }
    }

    /// Load image directly from endpoint
    static func getImage(
            endpoint: String,
            token: String,
            bypassCache: Bool = false) async throws -> UIImage?
        {
        // Only add cache-busting when explicitly requested (e.g., after upload)
        let cacheBuster = bypassCache ? "?t=\(Int(Date().timeIntervalSince1970))" : ""
        let url = Constants.API.baseURL + endpoint + cacheBuster
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("image/jpeg", forHTTPHeaderField: "Accept")
        
        // Use default cache policy for normal loads, ignore cache only when needed
        request.cachePolicy = bypassCache ? .reloadIgnoringLocalCacheData : .returnCacheDataElseLoad
        
        // Set reasonable timeout
        request.timeoutInterval = 10.0

        let (data, response) = try await URLSession.shared.data(for: request)

        // Check if response is 404 (no profile picture)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 {
                return nil // No profile picture found
            }

            if httpResponse.statusCode >= 400 {
                print("❌ HTTP Error \(httpResponse.statusCode) for image endpoint: \(endpoint)")
                throw NetworkError.invalidResponse
            }
        }

        guard let image = UIImage(data: data) else {
            throw NetworkError.invalidImageData
        }

        return image
    }

    /// Generic GET request that handles 404 as "no data" rather than error
    static func getWith404Handling<T: Codable>(
        endpoint: String,
        token: String,
        responseType: T.Type) async throws -> T?
    {
        let url = Constants.API.baseURL + endpoint
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        // Check if response is HTML (error page)
        if let httpResponse = response as? HTTPURLResponse {
            let contentType = httpResponse.allHeaderFields["Content-Type"] as? String ?? ""
            if contentType.contains("text/html") {
                print("❌ Server returned HTML instead of JSON for endpoint: \(endpoint)")
                print("❌ Response status: \(httpResponse.statusCode)")
                if let htmlString = String(data: data, encoding: .utf8) {
                    print("❌ HTML response: \(htmlString.prefix(200))...")
                }
                throw NetworkError.invalidResponse
            }

            if httpResponse.statusCode == 404 {
                // 404 means no data available, return nil instead of throwing error
                if let errorString = String(data: data, encoding: .utf8) {
                    print("ℹ️ No data found for endpoint: \(endpoint) - \(errorString)")
                }
                return nil
            }

            if httpResponse.statusCode >= 400 {
                print("❌ HTTP Error \(httpResponse.statusCode) for endpoint: \(endpoint)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error response: \(errorString)")
                }
                throw NetworkError.invalidResponse
            }
        }

        return try JSONDecoder().decode(responseType, from: data)
    }

    /// Generic GET request without authentication
    static func getWithoutAuth<T: Codable>(
        endpoint: String,
        responseType: T.Type) async throws -> T
    {
        let url = Constants.API.baseURL + endpoint
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        // Check if response is HTML (error page)
        if let httpResponse = response as? HTTPURLResponse {
            let contentType = httpResponse.allHeaderFields["Content-Type"] as? String ?? ""
            if contentType.contains("text/html") {
                print("❌ Server returned HTML instead of JSON for endpoint: \(endpoint)")
                print("❌ Response status: \(httpResponse.statusCode)")
                if let htmlString = String(data: data, encoding: .utf8) {
                    print("❌ HTML response: \(htmlString.prefix(200))...")
                }
                throw NetworkError.invalidResponse
            }

            if httpResponse.statusCode >= 400 {
                print("❌ HTTP Error \(httpResponse.statusCode) for endpoint: \(endpoint)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error response: \(errorString)")
                }
                throw NetworkError.invalidResponse
            }
        }

        return try JSONDecoder().decode(responseType, from: data)
    }
}

// MARK: - Network Error Types

enum NetworkError: Error {
    case invalidImageData
    case invalidResponse
    case authenticationFailed
    case noDataAvailable

    var localizedDescription: String {
        switch self {
            case .invalidImageData:
                return "Invalid image data"
            case .invalidResponse:
                return "Invalid response from server"
            case .authenticationFailed:
                return "Authentication failed"
            case .noDataAvailable:
                return "No data available"
        }
    }
}
