//
//  Device.swift
//  COEUSit
//

import Foundation

struct Device: Identifiable, Codable {
    let id: String
    let serialNumber: String
    let smileSerialNumber: String?
    let model: String
    let name: String?
    let status: String
    let configured: Bool
    let batteryPercent: Int
    let lastTemperature: Double?
    let lastHumidity: Double?
    let temperatureUnit: String?
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case serialNumber = "serial_number"
        case smileSerialNumber = "smile_serial_number"
        case model
        case name
        case status
        case configured
        case batteryPercent = "battery_percent"
        case lastTemperature = "last_temperature"
        case lastHumidity = "last_humidity"
        case temperatureUnit = "temperature_unit"
        case updatedAt = "updated_at"
    }
}

struct DeviceResponse: Codable {
    let page: Int
    let size: Int
    let total: Int
    let items: [Device]
}
