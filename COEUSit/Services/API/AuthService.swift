//
//  AuthService.swift
//  COEUSit
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String)
    case connectionError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The server URL is invalid."
        case .noData: return "No data was received from the server."
        case .decodingError(let error): return "Failed to process server response: \(error.localizedDescription)"
        case .serverError(let code, let message): return "Server error (\(code)): \(message)"
        case .connectionError(let error): return "Connection failed: \(error.localizedDescription)"
        }
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct RefreshRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct AuthService {
    private let baseURL = "https://stg-api.nd-gateway.com"
    
    func login(request: LoginRequest) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(0, "Invalid response type")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NetworkError.serverError(httpResponse.statusCode, serverMessage)
        }
        
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
    
    func refresh(request: RefreshRequest, accessToken: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/refresh") else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(0, "Invalid response type")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NetworkError.serverError(httpResponse.statusCode, serverMessage)
        }
        
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
}
