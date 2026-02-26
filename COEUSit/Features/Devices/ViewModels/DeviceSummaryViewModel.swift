//
//  DeviceSummaryViewModel.swift
//  COEUSit
//

import SwiftUI
import Combine
import Foundation

@MainActor
final class DeviceSummaryViewModel: ObservableObject {
    @Published var summary: DeviceSummary?
    @Published var isLoading = true
    @Published var error: Error?
    
    // Filters
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var selectedProbeType: String? = "Built-in"

    private let service = DeviceService()
    let deviceId: String

    init(deviceId: String) {
        self.deviceId = deviceId
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -1, to: end) ?? end
        self.endDate = end
        self.startDate = start
    }

    func fetchSummary(accessToken: String) async {
        isLoading = true
        error = nil
        
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)
        
        do {
            self.summary = try await service.fetchDeviceSummary(
                deviceId: deviceId,
                start: startString,
                end: endString,
                probeType: selectedProbeType,
                accessToken: accessToken
            )
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            print("Error fetching device summary: \(error)")
        }
    }
}
