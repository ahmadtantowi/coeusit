//
//  GroupService.swift
//  COEUSit
//

import Foundation

struct GroupService {
    private let baseURL = APIConfig.baseURL
    
    func fetchGroups(accessToken: String) async throws -> GroupResponse {
        guard let url = URL(string: "\(baseURL)/groups") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
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
            return try decoder.decode(GroupResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
