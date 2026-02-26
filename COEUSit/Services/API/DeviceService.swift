//
//  DeviceService.swift
//  COEUSit
//

import Foundation

struct DeviceService {
    private let baseURL = APIConfig.baseURL
    
    func fetchDevices(page: Int, pageSize: Int, searchText: String?, status: String?, accessToken: String) async throws -> DeviceResponse {
        var components = URLComponents(string: "\(baseURL)/devices")
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(pageSize)")
        ]
        
        if let searchText = searchText, !searchText.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: searchText))
        }
        
        if let status = status, !status.isEmpty {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
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
        do {
            return try decoder.decode(DeviceResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func fetchDeviceSummary(deviceId: String, start: String, end: String, probeType: String?, accessToken: String) async throws -> DeviceSummary {
        var components = URLComponents(string: "\(baseURL)/devices/\(deviceId)/records/summary")
        var queryItems = [
            URLQueryItem(name: "start", value: start),
            URLQueryItem(name: "end", value: end)
        ]
        
        if let probeType = probeType, !probeType.isEmpty {
            queryItems.append(URLQueryItem(name: "probe_type", value: probeType))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
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
        do {
            return try decoder.decode(DeviceSummary.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
