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
                        withName: "ImageFile",
                        fileName: "profile.jpg",
                        mimeType: "image/jpeg")
                },
                to: url,
                headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                        case let .success(data):
                            do {
                                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                                continuation.resume(returning: decodedResponse)
                            } catch {
                                print("❌ Image upload decoding error: \(error)")
                                continuation.resume(throwing: error)
                            }
                        case let .failure(error):
                            print("❌ Image upload error: \(error)")
                            continuation.resume(throwing: error)
                    }
                }
        }
    }
}

// MARK: - Network Error Types

enum NetworkError: Error {
    case invalidImageData
    case invalidResponse
    case authenticationFailed

    var localizedDescription: String {
        switch self {
            case .invalidImageData:
                return "Invalid image data"
            case .invalidResponse:
                return "Invalid response from server"
            case .authenticationFailed:
                return "Authentication failed"
        }
    }
}
