//
//  DashboardData.swift
//  COEUSit
//

import Foundation

struct DashboardData: Codable {
    let totalCount: Int
    let onlineCount: Int
    let offlineCount: Int
    let alarmCount: Int
    let lowBatteryCount: Int
    let unconfiguredCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case onlineCount = "online_count"
        case offlineCount = "offline_count"
        case alarmCount = "alarm_count"
        case lowBatteryCount = "low_battery_count"
        case unconfiguredCount = "unconfigured_count"
    }
    
    static var empty: DashboardData {
        DashboardData(
            totalCount: 0,
            onlineCount: 0,
            offlineCount: 0,
            alarmCount: 0,
            lowBatteryCount: 0,
            unconfiguredCount: 0
        )
    }
}
