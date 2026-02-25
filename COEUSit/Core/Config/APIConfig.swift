//
//  APIConfig.swift
//  COEUSit
//

import Foundation

enum APIConfig {
    private enum Keys {
        static let baseURL = "API_BASE_URL"
    }
    
    static var baseURL: String {
        // 1. Try to get from ProcessInfo (useful for tests/local debugging if set in scheme)
        if let envVar = ProcessInfo.processInfo.environment[Keys.baseURL], !envVar.isEmpty {
            return envVar
        }
        
        // 2. Try to get from Info.plist (populated by .xcconfig)
        if let infoPlistValue = Bundle.main.object(forInfoDictionaryKey: Keys.baseURL) as? String, !infoPlistValue.isEmpty {
            return infoPlistValue
        }
        
        // 3. Try to get from a bundled Config.plist
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let value = dict[Keys.baseURL] as? String, !value.isEmpty {
            return value
        }
        
        // 4. Fallback to default
        return "https://stg-api.nd-gateway.com"
    }
}
