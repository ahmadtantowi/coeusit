//
//  DashboardService.swift
//  COEUSit
//

import Foundation

struct DashboardService {
    private let baseURL = APIConfig.baseURL
    
    func getDashboard(accessToken: String) async throws -> DashboardData {
        guard let url = URL(string: "\(baseURL)/dashboard") else {
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
            return try decoder.decode(DashboardData.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
