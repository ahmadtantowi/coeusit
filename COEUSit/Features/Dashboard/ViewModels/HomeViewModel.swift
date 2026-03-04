//
//  HomeViewModel.swift
//  COEUSit
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var dashboardData: DashboardData = .empty
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    
    private let dashboardService = DashboardService()
    
    func fetchDashboardData(token: String) async {
        guard !token.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try await dashboardService.getDashboard(accessToken: token)
            dashboardData = data
            errorMessage = nil
            showErrorAlert = false
        } catch is CancellationError {
            return
        } catch {
            if (error as? URLError)?.code == .cancelled {
                return
            }
            
            errorMessage = error.localizedDescription
            print("Dashboard fetch error: \(error.localizedDescription)")
            
            // Small delay to allow refresh control to finish its animation 
            // before presenting the alert, which can sometimes cause it to hang.
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            showErrorAlert = true
        }
    }
}
