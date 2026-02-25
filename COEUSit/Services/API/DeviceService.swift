//
//  DeviceService.swift
//  COEUSit
//

import Foundation

struct DeviceService {
    private let baseURL = APIConfig.baseURL
    
    func fetchDevices(page: Int, pageSize: Int, accessToken: String) async throws -> DeviceResponse {
        var components = URLComponents(string: "\(baseURL)/devices")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(pageSize)")
        ]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(0, "Invalid response type")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NetworkError.serverError(httpResponse.statusCode, serverMessage)
        }
        
        let decoder = JSONDecoder()
        // Handle date strings if necessary, but for now we'll stick to strings as defined in the model
        return try decoder.decode(DeviceResponse.self, from: data)
    }
}
