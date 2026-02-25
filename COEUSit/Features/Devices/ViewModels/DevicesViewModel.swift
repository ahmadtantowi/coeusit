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
    
    // Search and Filter
    @Published var searchText: String = ""
    @Published var selectedStatus: String? = nil
    
    private var currentPage: Int = 1
    private let pageSize: Int = 20
    private var totalItems: Int = 0
    private var canLoadMorePages: Bool = true
    
    private let deviceService = DeviceService()
    private var fetchTask: Task<Void, Never>?
    
    func refresh(accessToken: String) async {
        await fetchInitialDevices(accessToken: accessToken)
    }

    func fetchInitialDevices(accessToken: String) async {
        fetchTask?.cancel()
        
        currentPage = 1
        devices = []
        canLoadMorePages = true
        
        fetchTask = Task {
            await fetchDevices(accessToken: accessToken)
        }
        await fetchTask?.value
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
            let response = try await deviceService.fetchDevices(
                page: currentPage,
                pageSize: pageSize,
                searchText: searchText.isEmpty ? nil : searchText,
                status: selectedStatus,
                accessToken: accessToken
            )
            
            if Task.isCancelled { return }
            
            if currentPage == 1 {
                devices = response.items
            } else {
                devices.append(contentsOf: response.items)
            }
            
            totalItems = response.total
            canLoadMorePages = devices.count < totalItems
            
        } catch {
            if !Task.isCancelled {
                self.error = error
                print("Error fetching devices: \(error)")
            }
        }
        
        isLoading = false
    }
}
