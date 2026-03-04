//
//  AuthService.swift
//  COEUSit
//

import Foundation

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
    private let baseURL = APIConfig.baseURL
    
    func login(request: LoginRequest) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(0, "Invalid response type")
        }
        
        if httpResponse.statusCode == 401 {
            NotificationCenter.default.post(name: .unauthorized, object: nil)
            throw NetworkError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NetworkError.serverError(httpResponse.statusCode, serverMessage)
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(LoginResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
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
        
        if httpResponse.statusCode == 401 {
            NotificationCenter.default.post(name: .unauthorized, object: nil)
            throw NetworkError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NetworkError.serverError(httpResponse.statusCode, serverMessage)
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(LoginResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func getUserProfile(accessToken: String) async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/profile") else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(0, "Invalid response type")
        }
        
        if httpResponse.statusCode == 401 {
            NotificationCenter.default.post(name: .unauthorized, object: nil)
            throw NetworkError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NetworkError.serverError(httpResponse.statusCode, serverMessage)
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
