//
//  DevicesViewModel.swift
//  COEUSit
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DevicesViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var currentPage: Int = 1
    private let pageSize: Int = 20 // Increased default page size
    private var totalItems: Int = 0
    private var canLoadMorePages: Bool = true
    
    private let deviceService = DeviceService()
    
    func fetchInitialDevices(accessToken: String) async {
        guard !isLoading else { return }
        
        currentPage = 1
        devices = []
        canLoadMorePages = true
        
        await fetchDevices(accessToken: accessToken)
    }
    
    func fetchNextPage(accessToken: String) async {
        guard !isLoading && canLoadMorePages else { return }
        
        currentPage += 1
        await fetchDevices(accessToken: accessToken)
    }
    
    private func fetchDevices(accessToken: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await deviceService.fetchDevices(page: currentPage, pageSize: pageSize, accessToken: accessToken)
            
            if currentPage == 1 {
                devices = response.items
            } else {
                devices.append(contentsOf: response.items)
            }
            
            totalItems = response.total
            // Check if we have loaded all items
            canLoadMorePages = devices.count < totalItems
            
        } catch {
            self.error = error
            print("Error fetching devices: \(error)")
        }
        
        isLoading = false
    }
}
