//
//  AuthManager.swift
//  COEUSit
//

import SwiftUI
import Combine

@MainActor
class AuthManager: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("accessToken") private var accessToken: String = ""
    @AppStorage("refreshToken") private var refreshToken: String = ""
    
    var token: String {
        accessToken
    }
    
    private let authService = AuthService()
    private var refreshCancellable: AnyCancellable?
    
    init() {
        if isLoggedIn {
            setupAutoRefresh()
        }
    }
    
    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        let response = try await authService.login(request: request)
        
        self.accessToken = response.accessToken
        self.refreshToken = response.refreshToken
        self.isLoggedIn = true
        self.setupAutoRefresh()
    }
    
    func logout() {
        isLoggedIn = false
        accessToken = ""
        refreshToken = ""
        refreshCancellable?.cancel()
    }
    
    func setupAutoRefresh() {
        refreshCancellable?.cancel()
        
        // Check every minute if token needs refresh
        refreshCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    guard self?.isLoggedIn == true else { return }
                    await self?.checkAndRefreshIfNeeded()
                }
            }
    }
    
    private func checkAndRefreshIfNeeded() async {
        guard !accessToken.isEmpty else { return }
        
        if isTokenExpiringSoon(token: accessToken) {
            do {
                let request = RefreshRequest(refreshToken: refreshToken)
                let response = try await authService.refresh(request: request, accessToken: accessToken)
                
                self.accessToken = response.accessToken
                self.refreshToken = response.refreshToken
                print("Token refreshed successfully")
            } catch {
                print("Failed to refresh token: \(error)")
                logout()
            }
        }
    }
    
    private func isTokenExpiringSoon(token: String) -> Bool {
        guard let expirationDate = decodeTokenExpiration(token: token) else {
            return true
        }
        return expirationDate.timeIntervalSinceNow < 300
    }
    
    private func decodeTokenExpiration(token: String) -> Date? {
        let segments = token.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }
        
        var base64 = segments[1]
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return nil
        }
        
        return Date(timeIntervalSince1970: exp)
    }
}
