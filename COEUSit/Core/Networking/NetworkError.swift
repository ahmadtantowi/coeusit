//
//  NetworkError.swift
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
